/// <summary>
/// Codeunit Shpfy Export Shipments (ID 30190).
/// </summary>
codeunit 30190 "Shpfy Export Shipments"
{
    Access = Internal;
    Permissions =
        tabledata "Sales Shipment Header" = rm,
        tabledata "Sales Shipment Line" = r,
        tabledata "Shipping Agent" = r;

    var
        ShopifyCommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        ShippingEvents: Codeunit "Shpfy Shipping Events";

    /// <summary> 
    /// Create Shopify Fulfillment.
    /// </summary>
    /// <param name="SalesShipmentHeader">Parameter of type Record "Sales Shipment Header".</param>
    internal procedure CreateShopifyFulfillment(var SalesShipmentHeader: Record "Sales Shipment Header");
    var
        ShipmentLocation: Query "Shpfy Shipment Location";
    begin
        if (SalesShipmentHeader."Shpfy Order Id" <> 0) and (SalesShipmentHeader."Shpfy Fulfillment Id" = 0) then begin
            ShipmentLocation.SetRange(No, SalesShipmentHeader."No.");
            if ShipmentLocation.Open() then
                while ShipmentLocation.Read() do
                    CreateShopifyFulfillment(SalesShipmentHeader, ShipmentLocation.LocationId, ShipmentLocation.LocationCode);
        end;
    end;

    local procedure CreateShopifyFulfillment(var SalesShipmentHeader: Record "Sales Shipment Header"; LocationId: BigInteger; LocationCode: Code[10]);
    var
        ShopifyOrderHeader: Record "Shpfy Order Header";
        OrderFulfillments: Codeunit "Shpfy Order Fulfillments";
        JsonHelper: Codeunit "Shpfy Json Helper";
        JFulfillment: JsonToken;
        JResponse: JsonToken;
        FulfillmentOrderRequest: Text;
    begin
        if ShopifyOrderHeader.Get(SalesShipmentHeader."Shpfy Order Id") then begin
            ShopifyCommunicationMgt.SetShop(ShopifyOrderHeader."Shop Code");
            FulfillmentOrderRequest := CreateFulfillmentOrderRequest(SalesShipmentHeader, LocationId, LocationCode);
            if FulfillmentOrderRequest <> '' then begin
                JResponse := ShopifyCommunicationMgt.ExecuteGraphQL(FulfillmentOrderRequest);
                JFulfillment := JsonHelper.GetJsonToken(JResponse, 'data.fulfillmentCreateV2.fulfillment');
                if (JFulfillment.IsObject) then
                    SalesShipmentHeader."Shpfy Fulfillment Id" := OrderFulfillments.ImportFulfillment(SalesShipmentHeader."Shpfy Order Id", JFulfillment)
                else
                    SalesShipmentHeader."Shpfy Fulfillment Id" := -1;
            end else
                SalesShipmentHeader."Shpfy Fulfillment Id" := -1;
            SalesShipmentHeader.Modify(true);
        end;
    end;

    internal procedure CreateFulfillmentOrderRequest(SalesShipmentHeader: Record 110; LocationId: BigInteger; LocationCode: Code[10]) Request: Text;
    var
        SalesShipmentLine: Record "Sales Shipment Line";
        ShippingAgent: Record "Shipping Agent";
        FulfillmentOrderLine: Record "Shpfy FulFillment Order Line";
        TempFulfillmentOrderLine: Record "Shpfy FulFillment Order Line" temporary;
        TrackingCompany: Enum "Shpfy Tracking Companies";
        PrevFulfillmentOrderId: BigInteger;
        IsHandled: Boolean;
        TrackingUrl: Text;
        GraphQuery: TextBuilder;
    begin
        Clear(PrevFulfillmentOrderId);

        SalesShipmentLine.Reset();
        SalesShipmentLine.SetRange("Document No.", SalesShipmentHeader."No.");
        SalesShipmentLine.SetRange(Type, SalesShipmentLine.Type::Item);
        SalesShipmentLine.SetFilter("Shpfy Order Line Id", '<>%1', 0);
        SalesShipmentLine.SetFilter(Quantity, '>%1', 0);
        if SalesShipmentLine.FindSet() then begin
            repeat
                if FindFulfillmentOrderLine(SalesShipmentHeader, SalesShipmentLine, FulfillmentOrderLine) then begin
                    FulfillmentOrderLine."Quantity to Fulfill" += Round(SalesShipmentLine.Quantity, 1, '=');
                    FulfillmentOrderLine."Remaining Quantity" := FulfillmentOrderLine."Remaining Quantity" - Round(SalesShipmentLine.Quantity, 1, '=');
                    FulfillmentOrderLine.Modify();
                    if TempFulfillmentOrderLine.Get(FulfillmentOrderLine."Shopify Fulfillment Order Id", FulfillmentOrderLine."Shopify Fulfillm. Ord. Line Id") then begin
                        TempFulfillmentOrderLine."Quantity to Fulfill" += FulfillmentOrderLine."Quantity to Fulfill";
                        TempFulfillmentOrderLine.Modify();
                    end else begin
                        TempFulfillmentOrderLine := FulfillmentOrderLine;
                        TempFulfillmentOrderLine."Quantity to Fulfill" := Round(SalesShipmentLine.Quantity, 1, '=');
                        TempFulfillmentOrderLine.Insert();
                    end;
                end;
            until SalesShipmentLine.Next() = 0;

            TempFulfillmentOrderLine.Reset();
            if TempFulfillmentOrderLine.FindSet() then begin
                GraphQuery.Append('{"query": "mutation {fulfillmentCreateV2( fulfillment: {');
                GraphQuery.Append('notifyCustomer: true, ');
                if SalesShipmentHeader."Package Tracking No." <> '' then begin
                    GraphQuery.Append('trackingInfo: {');
                    if SalesShipmentHeader."Shipping Agent Code" <> '' then begin
                        GraphQuery.Append('company: \"');
                        if ShippingAgent.Get(SalesShipmentHeader."Shipping Agent Code") then begin
                            if ShippingAgent."Shpfy Tracking Company" = ShippingAgent."Shpfy Tracking Company"::" " then begin
                                if ShippingAgent.Name = '' then
                                    GraphQuery.Append(ShippingAgent.Code)
                                else
                                    GraphQuery.Append(ShippingAgent.Code)
                            end else
                                GraphQuery.Append(TrackingCompany.Names.Get(TrackingCompany.Ordinals.IndexOf(ShippingAgent."Shpfy Tracking Company".AsInteger())));
                        end else
                            GraphQuery.Append('""');
                        GraphQuery.Append('\",');
                    end;

                    GraphQuery.Append('number: \"');
                    GraphQuery.Append(SalesShipmentHeader."Package Tracking No.");
                    GraphQuery.Append('\",');
                    GraphQuery.Append('url: \"');
                    ShippingEvents.BeforeRetrieveTrackingUrl(SalesShipmentHeader, TrackingUrl, IsHandled);
                    if not IsHandled then
                        if ShippingAgent."Internet Address" <> '' then
                            TrackingUrl := ShippingAgent.GetTrackingInternetAddr(SalesShipmentHeader."Package Tracking No.");
                    GraphQuery.Append(TrackingUrl);
                    GraphQuery.Append('\"');
                    GraphQuery.Append('}');
                end;
                GraphQuery.Append('lineItemsByFulfillmentOrder: [');
                repeat
                    if PrevFulfillmentOrderId <> TempFulfillmentOrderLine."Shopify Fulfillment Order Id" then begin
                        if PrevFulfillmentOrderId <> 0 then
                            GraphQuery.Append(']},');

                        GraphQuery.Append('{');
                        GraphQuery.Append('fulfillmentOrderId: \"gid://shopify/FulfillmentOrder/');
                        GraphQuery.Append(Format(TempFulfillmentOrderLine."Shopify Fulfillment Order Id"));
                        GraphQuery.Append('\",');
                        GraphQuery.Append('fulfillmentOrderLineItems: [');
                        PrevFulfillmentOrderId := TempFulfillmentOrderLine."Shopify Fulfillment Order Id";
                    end else
                        GraphQuery.Append(',');
                    GraphQuery.Append('{');
                    GraphQuery.Append('id: \"gid://shopify/FulfillmentOrderLineItem/');
                    GraphQuery.Append(Format(TempFulfillmentOrderLine."Shopify Fulfillm. Ord. Line Id"));
                    GraphQuery.Append('\",');
                    GraphQuery.Append('quantity: ');
                    GraphQuery.Append(Format(TempFulfillmentOrderLine."Quantity to Fulfill"));
                    GraphQuery.Append('}');
                until TempFulfillmentOrderLine.Next() = 0;
                GraphQuery.Append(']}]})');
                GraphQuery.Append('{fulfillment { legacyResourceId name createdAt updatedAt deliveredAt displayStatus estimatedDeliveryAt status totalQuantity location { legacyResourceId } trackingInfo { number url company } service { serviceName type shippingMethods { code label }} fulfillmentLineItems(first: 10) { pageInfo { endCursor hasNextPage } nodes { id quantity originalTotalSet { presentmentMoney { amount } shopMoney { amount }} lineItem { id product { isGiftCard }}}}}}}"}');
            end;
            exit(GraphQuery.ToText());
        end;
    end;

    local procedure FindFulfillmentOrderLine(SalesShipmentHeader: record "Sales Shipment Header"; SalesShipmentLine: record "Sales Shipment Line"; var FulfillmentOrderLine: record "Shpfy FulFillment Order Line"): Boolean
    var
        OrderLine: Record "Shpfy Order Line";
    begin
        if OrderLine.Get(SalesShipmentHeader."Shpfy Order Id", SalesShipmentLine."Shpfy Order Line Id") then begin
            FulfillmentOrderLine.Reset();
            FulfillmentOrderLine.SetRange("Shopify Order Id", OrderLine."Shopify Order Id");
            FulfillmentOrderLine.SetRange("Shopify Variant Id", OrderLine."Shopify Variant Id");
            FulfillmentOrderLine.SetFilter("Remaining Quantity", '>=%1', Round(SalesShipmentLine.Quantity, 1, '='));
            if FulfillmentOrderLine.FindFirst() then
                exit(true);
        end;
    end;

    internal procedure CreateFulfillmentRequest(SalesShipmentHeader: Record 110; LocationId: BigInteger; LocationCode: Code[10]) Request: Text;
    var
        SalesShipmentLine: Record "Sales Shipment Line";
        ShippingAgent: Record "Shipping Agent";
        TrackingCompany: Enum "Shpfy Tracking Companies";
        IsHandled: Boolean;
        TrackingUrl: Text;
        GraphQuery: TextBuilder;
        LinesBuilder: TextBuilder;
    begin
        SalesShipmentLine.Reset();
        SalesShipmentLine.SetRange("Document No.", SalesShipmentHeader."No.");
        SalesShipmentLine.SetRange(Type, SalesShipmentLine.Type::Item);
        SalesShipmentLine.SetFilter("Shpfy Order Line Id", '<>%1', 0);
        SalesShipmentLine.SetFilter(Quantity, '>%1', 0);
        SalesShipmentLine.SetRange("Location Code", LocationCode);
        if SalesShipmentLine.FindSet() then begin
            repeat
                if LinesBuilder.Length > 0 then
                    LinesBuilder.Append(', ');
                LinesBuilder.Append('{id: \"gid://shopify/LineItem/');
                LinesBuilder.Append(Format(SalesShipmentLine."Shpfy Order Line Id"));
                LinesBuilder.Append('\", quantity: ');
                LinesBuilder.Append(Format(SalesShipmentLine.Quantity));
                LinesBuilder.Append('}');
            until SalesShipmentLine.Next() = 0;

            GraphQuery.Append('{"query": "mutation { fulfillmentCreate(input: {orderId: \"gid://shopify/Order/');
            GraphQuery.Append(Format(SalesShipmentHeader."Shpfy Order Id"));
            GraphQuery.Append('\", locationId: \"gid://shopify/Location/');
            GraphQuery.Append(Format(LocationId));
            GraphQuery.Append('\", notifyCustomer: true, ');
            if SalesShipmentHeader."Package Tracking No." <> '' then begin
                GraphQuery.Append('trackingCompany: \"');
                if SalesShipmentHeader."Shipping Agent Code" <> '' then
                    if ShippingAgent.Get(SalesShipmentHeader."Shipping Agent Code") then begin
                        if ShippingAgent."Shpfy Tracking Company" = ShippingAgent."Shpfy Tracking Company"::" " then begin
                            if ShippingAgent.Name = '' then
                                GraphQuery.Append(ShippingAgent.Code)
                            else
                                GraphQuery.Append(ShippingAgent.Code)
                        end else
                            GraphQuery.Append(TrackingCompany.Names.Get(TrackingCompany.Ordinals.IndexOf(ShippingAgent."Shpfy Tracking Company".AsInteger())));
                    end else
                        GraphQuery.Append('""');

                GraphQuery.Append('\", trackingNumbers: \"');
                GraphQuery.Append(SalesShipmentHeader."Package Tracking No.");
                GraphQuery.Append('\", trackingUrls: \"');
                ShippingEvents.BeforeRetrieveTrackingUrl(SalesShipmentHeader, TrackingUrl, IsHandled);
                if not IsHandled then
                    TrackingUrl := ShippingAgent.GetTrackingInternetAddr(SalesShipmentHeader."Package Tracking No.");
                GraphQuery.Append(TrackingUrl);
                GraphQuery.Append('\", ');
            end;
            GraphQuery.Append('lineItems: [');
            GraphQuery.Append(LinesBuilder.ToText());
            GraphQuery.Append(']}) {fulfillment { legacyResourceId name createdAt updatedAt deliveredAt displayStatus estimatedDeliveryAt status totalQuantity location { legacyResourceId } trackingInfo { number url company } service { serviceName type shippingMethods { code label }} fulfillmentLineItems(first: 10) { pageInfo { endCursor hasNextPage } nodes { id quantity originalTotalSet { presentmentMoney { amount } shopMoney { amount }} lineItem { id product { isGiftCard }}}}}}}"}');
            exit(GraphQuery.ToText());
        end;
    end;
}