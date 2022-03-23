/// <summary>
/// PageExtension Shpfy Posted Sales Inv. Ext. (ID 30160) extends Record Posted Sales Invoice.
/// </summary>
pageextension 30106 "Shpfy Posted Sales Inv. Ext." extends "Posted Sales Invoice"
{
    layout
    {
        addafter("Order No.")
        {
            field(ShpfyOrderNo; Rec."Shpfy Order No.")
            {
                ApplicationArea = All;
                DrillDown = true;
                ToolTip = 'Specifies the order number from Shopify';

                trigger OnDrillDown()
                var
                    ShopifyOrderMgt: Codeunit "Shpfy Order Mgt.";
                    VariantRec: Variant;
                begin
                    VariantRec := Rec;
                    ShopifyOrderMgt.ShowShopifyOrder(VariantRec);
                end;
            }
        }
    }
}