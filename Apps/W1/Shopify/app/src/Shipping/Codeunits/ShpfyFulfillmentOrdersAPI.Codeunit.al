codeunit 30238 "Shpfy Fulfillment Orders API"
{
    var
        CommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        JsonHelper: Codeunit "Shpfy Json Helper";
        GraphQLType: Enum "Shpfy GraphQL Type";


    internal procedure RegisterFulfillmentService(var Shop: Record "Shpfy Shop")
    var
        Parameters: Dictionary of [Text, Text];
        JResponse: JsonToken;
    begin
        CommunicationMgt.SetShop(Shop);
        GraphQLType := "Shpfy GraphQL Type"::CreateFulfillmentService;
        JResponse := CommunicationMgt.ExecuteGraphQL(GraphQLType, Parameters);

        Shop."Fulfillmentservice Activated" := true;
        Shop.Modify();
    end;

    internal procedure GetShopifyFulfillmentOrders()
    var
        Shop: Record "Shpfy Shop";
    begin
        Shop.Reset();
        if Shop.FindSet() then
            repeat
                if not Shop."Fulfillmentservice Activated" then
                    RegisterFulfillmentService(Shop);

                GetShopifyFulFillmentOrders(Shop);
            until Shop.Next() = 0;
    end;

    internal procedure GetShopifyFulFillmentOrders(Shop: Record "Shpfy Shop")
    var
        Cursor: Text;
        Parameters: Dictionary of [Text, Text];
        JResponse: JsonToken;
    begin
        CommunicationMgt.SetShop(Shop);

        GraphQLType := "Shpfy GraphQL Type"::GetOpenFulfillmentOrders;
        repeat
            JResponse := CommunicationMgt.ExecuteGraphQL(GraphQLType, Parameters);
            if JResponse.IsObject() then
                if ExtractFulfillmentOrders(Shop, JResponse.AsObject(), Cursor) then begin
                    if Parameters.ContainsKey('After') then
                        Parameters.Set('After', Cursor)
                    else
                        Parameters.Add('After', Cursor);
                    GraphQLType := "Shpfy GraphQL Type"::GetNextOpenFulfillmentOrders;
                end else
                    break;
        until not JsonHelper.GetValueAsBoolean(JResponse, 'data.fulfillmentOrders.pageInfo.hasNextPage');
        Commit();
    end;

    internal procedure GetFulFillmentOrderLines(Shop: Record "Shpfy Shop"; FulfillmentOrderHeader: Record "Shpfy FulFillment Order Header")
    var
        Cursor: Text;
        Parameters: Dictionary of [Text, Text];
        JResponse: JsonToken;
    begin
        CommunicationMgt.SetShop(Shop);

        Parameters.Add('FulfillmentOrderId', format(FulfillmentOrderHeader."Shopify Fulfillment Order Id"));

        GraphQLType := "Shpfy GraphQL Type"::GetOpenFulfillmentOrderLines;
        repeat
            JResponse := CommunicationMgt.ExecuteGraphQL(GraphQLType, Parameters);
            if JResponse.IsObject() then
                if ExtractFulfillmentOrderLines(Shop, FulfillmentOrderHeader, JResponse.AsObject(), Cursor) then begin
                    if Parameters.ContainsKey('After') then
                        Parameters.Set('After', Cursor)
                    else
                        Parameters.Add('After', Cursor);
                    GraphQLType := "Shpfy GraphQL Type"::GetNextOpenFulfillmentOrderLines;
                end else
                    break;
        until not JsonHelper.GetValueAsBoolean(JResponse, 'data.fulfillmentOrder.lineItems.pageInfo.hasNextPage');
        Commit();
    end;

    internal procedure ExtractFulfillmentOrders(var ShopifyShop: Record "Shpfy Shop"; JResponse: JsonObject; var Cursor: Text): Boolean
    var
        FulfillmentOrderHeader: Record "Shpfy FulFillment Order Header";
        Id: BigInteger;
        JFulfillmentOrders: JsonArray;
        JNode: JsonObject;
        JItem: JsonToken;
    begin
        if JsonHelper.GetJsonArray(JResponse, JFulfillmentOrders, 'data.fulfillmentOrders.edges') then begin
            foreach JItem in JFulfillmentOrders do begin
                Cursor := JsonHelper.GetValueAsText(JItem.AsObject(), 'cursor');
                if JsonHelper.GetJsonObject(JItem.AsObject(), JNode, 'node') then begin
                    Id := CommunicationMgt.GetIdOfGId(JsonHelper.GetValueAsText(JNode, 'id'));

                    FulfillmentOrderHeader.SetRange("Shopify Fulfillment Order Id", Id);
                    if not FulfillmentOrderHeader.FindFirst() then
                        Clear(FulfillmentOrderHeader);
                    FulfillmentOrderHeader."Shopify Fulfillment Order Id" := Id;
                    FulfillmentOrderHeader."Shop Id" := ShopifyShop."Shop Id";
                    FulfillmentOrderHeader."Shop Code" := ShopifyShop.Code;
                    FulfillmentOrderHeader."Shopify Order Id" := JsonHelper.GetValueAsBigInteger(JNode, 'order.legacyResourceId');
                    if not FulfillmentOrderHeader.Insert() then
                        FulfillmentOrderHeader.Modify();
                    GetFulfillmentOrderLines(ShopifyShop, FulfillmentOrderHeader);
                end;
            end;
            exit(true);
        end;
    end;

    internal procedure ExtractFulfillmentOrderLines(var ShopifyShop: Record "Shpfy Shop"; var FulfillmentOrderHeader: Record "Shpfy FulFillment Order Header"; JResponse: JsonObject; var Cursor: Text): Boolean
    var
        FulfillmentOrderLine: Record "Shpfy FulFillment Order Line";
        Id: BigInteger;
        JFulfillmentOrderLines: JsonArray;
        JNode: JsonObject;
        JItem: JsonToken;
    begin
        if JsonHelper.GetJsonArray(JResponse, JFulfillmentOrderLines, 'data.fulfillmentOrder.lineItems.edges') then begin
            foreach JItem in JFulfillmentOrderLines do begin
                Cursor := JsonHelper.GetValueAsText(JItem.AsObject(), 'cursor');
                if JsonHelper.GetJsonObject(JItem.AsObject(), JNode, 'node') then begin
                    Id := CommunicationMgt.GetIdOfGId(JsonHelper.GetValueAsText(JNode, 'id'));

                    FulfillmentOrderLine.SetRange("Shopify Fulfillm. Ord. Line Id", Id);
                    if not FulfillmentOrderLine.FindFirst() then
                        Clear(FulfillmentOrderLine);

                    FulfillmentOrderLine."Shopify Fulfillment Order Id" := FulfillmentOrderHeader."Shopify Fulfillment Order Id";
                    FulfillmentOrderLine."Shopify Fulfillm. Ord. Line Id" := Id;
                    FulfillmentOrderLine."Shopify Order Id" := FulfillmentOrderHeader."Shopify Order Id";
                    FulfillmentOrderLine."Shopify Product Id" := JsonHelper.GetValueAsBigInteger(JNode, 'lineItem.product.legacyResourceId');
                    FulfillmentOrderLine."Shopify Variant Id" := JsonHelper.GetValueAsBigInteger(JNode, 'lineItem.variant.legacyResourceId');
                    FulfillmentOrderLine."Total Quantity" := JsonHelper.GetValueAsDecimal(JNode, 'totalQuantity');
                    FulfillmentOrderLine."Remaining Quantity" := JsonHelper.GetValueAsDecimal(JNode, 'remainingQuantity');

                    if not FulfillmentOrderLine.Insert() then
                        FulfillmentOrderLine.Modify();
                end;
            end;
            exit(true);
        end;
    end;
}