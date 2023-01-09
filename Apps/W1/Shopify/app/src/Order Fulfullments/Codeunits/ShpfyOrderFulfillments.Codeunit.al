/// <summary>
/// Codeunit Shpfy Order Fulfillments (ID 30160).
/// </summary>
codeunit 30160 "Shpfy Order Fulfillments"
{
    Access = Internal;

    var
        CommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        JsonHelper: Codeunit "Shpfy Json Helper";

    local procedure ConvertToFulFillmentStatus(Value: Text): Enum "Shpfy Fulfillment Status"
    begin
        Value := CommunicationMgt.ConvertToCleanOptionValue(Value);
        if Enum::"Shpfy Fulfillment Status".Names().Contains(Value) then
            exit(Enum::"Shpfy Fulfillment Status".FromInteger(Enum::"Shpfy Fulfillment Status".Ordinals().Get(Enum::"Shpfy Fulfillment Status".Names().IndexOf(Value))))
        else
            exit(Enum::"Shpfy Fulfillment Status"::" ");
    end;

    local procedure ConvertToShipmentStatus(Value: Text): Enum "Shpfy Shipment Status"
    begin
        Value := CommunicationMgt.ConvertToCleanOptionValue(Value);
        if Enum::"Shpfy Shipment Status".Names().Contains(Value) then
            exit(Enum::"Shpfy Shipment Status".FromInteger(Enum::"Shpfy Shipment Status".Ordinals().Get(Enum::"Shpfy Shipment Status".Names().IndexOf(Value))))
        else
            exit(Enum::"Shpfy Shipment Status"::" ");
    end;

    internal procedure GetFulfillments(ShpfyShop: Record "Shpfy Shop"; OrderId: BigInteger)
    var
        Parameters: Dictionary of [Text, Text];
        ShpfyGraphQLType: Enum "Shpfy GraphQL Type";
        JOrder: JsonObject;
        JFulfillments: JsonArray;
        JResponse: JsonToken;
    begin
        if CommunicationMgt.GetTestInProgress() then
            exit;
        CommunicationMgt.SetShop(ShpfyShop);
        Parameters.Add('OrderId', Format(OrderId));
        ShpfyGraphQLType := "Shpfy GraphQL Type"::GetOrderFulfillment;
        JResponse := CommunicationMgt.ExecuteGraphQL(ShpfyGraphQLType, Parameters);
        if JsonHelper.GetJsonObject(JResponse, JOrder, 'data.order') then
            if JsonHelper.GetValueAsBigInteger(JOrder, 'legacyResourceId') = OrderId then begin
                JFulfillments := JsonHelper.GetJsonArray(JOrder, 'fulfillments');
                GetFulfillmentInfos(OrderId, JFulfillments);
            end;
    end;

    /// <summary> 
    /// Get FulFillment Infos.
    /// </summary>
    /// <param name="OrderId">Parameter of type BigInteger.</param>
    /// <param name="JFulfillments">Parameter of type JsonArray.</param>
    internal procedure GetFulfillmentInfos(OrderId: BigInteger; JFulfillments: JsonArray)
    var
        JToken: JsonToken;
    begin
        foreach Jtoken in JFulfillments do
            ImportFulfillment(OrderId, JToken);
    end;

    /// <summary> 
    /// Description for ImportFulfillment.
    /// </summary>
    /// <param name="JFulfillment">Parameter of type JsonToken.</param>
    /// <returns>Return variable "BigInteger".</returns>
    internal procedure ImportFulfillment(OrderId: BigInteger; JFulfillment: JsonToken): BigInteger
    var
        DataCapture: Record "Shpfy Data Capture";
        OrderFulfillment: Record "Shpfy Order Fulfillment";
        ShpfyGiftCards: Codeunit "Shpfy Gift Cards";
        OrderFulfillmentRecordRef: RecordRef;
        Id: BigInteger;
        HasNextPage: Boolean;
        IsNew: Boolean;
        Parameters: Dictionary of [Text, Text];
        ShpfyGraphQLType: Enum "Shpfy GraphQL Type";
        JArray: JsonArray;
        JResponse: JsonToken;
        JTracking: JsonToken;
        TrackingCompanies: Text;
        TrackingNos: Text;
        TrackingUrls: Text;
    begin
        Id := JsonHelper.GetValueAsBigInteger(JFulfillment, 'legacyResourceId');
        IsNew := not OrderFulfillment.Get(Id);
        if IsNew then begin
            Clear(OrderFulfillment);
            OrderFulfillment."Shopify Fulfillment Id" := Id;
            OrderFulfillment."Shopify Order Id" := OrderId;
        end else
            if OrderFulfillment."Updated At" = JsonHelper.GetValueAsDateTime(JFulfillment, 'updatedAt') then
                exit;
        OrderFulfillment.Status := ConvertToFulFillmentStatus(JsonHelper.GetValueAsText(JFulfillment, 'status'));
        OrderFulfillmentRecordRef.GetTable(OrderFulfillment);
        JsonHelper.GetValueIntoField(JFulfillment, 'createdAt', OrderFulfillmentRecordRef, OrderFulfillment.FieldNo("Created At"));
        JsonHelper.GetValueIntoField(JFulfillment, 'updatedAt', OrderFulfillmentRecordRef, OrderFulfillment.FieldNo("Updated At"));
        JsonHelper.GetValueIntoField(JFulfillment, 'name', OrderFulfillmentRecordRef, OrderFulfillment.FieldNo(Name));
        JsonHelper.GetValueIntoField(JFulfillment, 'service.serviceName', OrderFulfillmentRecordRef, OrderFulfillment.FieldNo(Service));
        JArray := JsonHelper.GetJsonArray(JFulfillment, 'trackingInfo');

        foreach JTracking in JArray do begin
            if (TrackingNos = '') and (TrackingUrls = '') and (TrackingCompanies = '') then begin
                JsonHelper.GetValueIntoField(JTracking, 'number', OrderFulfillmentRecordRef, OrderFulfillment.FieldNo("Tracking Number"));
                JsonHelper.GetValueIntoField(JTracking, 'url', OrderFulfillmentRecordRef, OrderFulfillment.FieldNo("Tracking URL"));
                JsonHelper.GetValueIntoField(JTracking, 'company', OrderFulfillmentRecordRef, OrderFulfillment.FieldNo("Tracking Company"));
            end else begin
                TrackingNos := TrackingNos + ',';
                TrackingUrls := TrackingUrls + ',';
                TrackingCompanies := TrackingCompanies + ',';
            end;
            TrackingNos := TrackingNos + JsonHelper.GetValueAsText(JTracking, 'number');
            TrackingUrls := TrackingUrls + JsonHelper.GetValueAsText(JTracking, 'url');
            TrackingCompanies := TrackingCompanies + JsonHelper.GetValueAsText(JTracking, 'company');
        end;

        OrderFulfillmentRecordRef.SetTable(OrderFulfillment);
        OrderFulfillment."Tracking Numbers" := CopyStr(TrackingNos, 1, MaxStrLen(OrderFulfillment."Tracking Numbers"));
        OrderFulfillment."Tracking URLs" := CopyStr(TrackingUrls, 1, MaxStrLen(OrderFulfillment."Tracking URLs"));
        OrderFulfillment."Tracking Companies" := CopyStr(TrackingCompanies, 1, MaxStrLen(OrderFulfillment."Tracking Companies"));
        if IsNew then
            OrderFulfillment.Insert()
        else
            OrderFulfillment.Modify();

        OrderFulfillmentRecordRef.Close();

        repeat
            FillInFulFillItemLines(OrderId, OrderFulfillment."Shopify Fulfillment Id", JsonHelper.GetJsonArray(JFulfillment, 'fulfillmentLineItems.nodes'));
            HasNextPage := JsonHelper.GetValueAsBoolean(JFulfillment, 'fulfillmentLineItems.pageInfo.hasNextPage');
            if HasNextPage then begin
                if Parameters.ContainsKey('FulfillmentId') then
                    Parameters.Set('FulfillmentId', Format(OrderFulfillment."Shopify Fulfillment Id"))
                else
                    Parameters.Add('FulfillmentId', Format(OrderFulfillment."Shopify Fulfillment Id"));
                if Parameters.ContainsKey('After') then
                    Parameters.Set('After', JsonHelper.GetValueAsText(JFulfillment, 'fulfillmentLineItems.pageInfo.endCursor'))
                else
                    Parameters.Add('After', JsonHelper.GetValueAsText(JFulfillment, 'fulfillmentLineItems.pageInfo.endCursor'));
                ShpfyGraphQLType := "Shpfy GraphQL Type"::GetNextOrderFulfillmentLines;
                JResponse := CommunicationMgt.ExecuteGraphQL(ShpfyGraphQLType, Parameters);
                JFulfillment := JsonHelper.GetJsonToken(JResponse, 'data.fulfillment');
            end;
        until not HasNextPage;


        OrderFulfillment.CalcFields("Contains Gift Cards");
        if OrderFulfillment."Contains Gift Cards" then
            if JsonHelper.GetJsonArray(JFulfillment, JArray, 'receipt.gift_cards') then
                ShpfyGiftCards.AddSoldGiftCards(JArray);

        DataCapture.Add(Database::"Shpfy Order Fulfillment", OrderFulfillment.SystemId, JFulfillment);
        exit(id);
    end;

    local procedure FillInFulFillItemLines(OrderId: BigInteger; FulfillmentId: BigInteger; JFulfillmentLines: JsonArray)
    var
        ShpfyFulfillmentLine: Record "Shpfy Fulfillment Line";
        Id: BigInteger;
        JFulFillmentLine: JsonToken;
    begin
        foreach JFulfillmentLine in JFulfillmentLines do begin
            Id := CommunicationMgt.GetIdOfGId(JsonHelper.GetValueAsText(JFulFillmentLine, 'id'));
            ShpfyFulfillmentLine.SetRange("Fulfillment Line Id", Id);
            if not ShpfyFulfillmentLine.FindFirst() then begin
                ShpfyFulfillmentLine."Fulfillment Line Id" := Id;
                ShpfyFulfillmentLine.Insert();
            end;
            ShpfyFulfillmentLine."Order Id" := OrderId;
            ShpfyFulfillmentLine."Fulfillment Id" := FulfillmentId;
            ShpfyFulfillmentLine."Order Line Id" := CommunicationMgt.GetIdOfGId(JsonHelper.GetValueAsText(JFulFillmentLine, 'lineItem.id'));
            ShpfyFulfillmentLine.Quantity := JsonHelper.GetValueAsInteger(JFulFillmentLine, 'quantity');
            ShpfyFulfillmentLine."Is Gift Card" := JsonHelper.GetValueAsBoolean(JFulfillmentLine, 'lineItem.product.isGiftCard');
            ShpfyFulfillmentLine.Modify();
        end;
    end;
}