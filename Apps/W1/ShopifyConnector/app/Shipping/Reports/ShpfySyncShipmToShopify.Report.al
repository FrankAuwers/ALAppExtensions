/// <summary>
/// Report Shpfy Shipments To Shopify (ID 30109).
/// </summary>
report 30109 "Shpfy Sync Shipm. To Shopify"
{
    ApplicationArea = All;
    Caption = 'Shopify Sync Shipments To Shopify';
    ProcessingOnly = true;
    UsageCategory = Tasks;

    dataset
    {
        dataitem("Sales Shipment Header"; "Sales Shipment Header")
        {
            RequestFilterFields = "No.", "Posting Date";

            trigger OnPreDataItem();
            begin
                SetFilter("Shpfy Order Id", '<>%1', 0);
                SetRange("Shpfy Fulfillment Id", 0);
            end;

            trigger OnAfterGetRecord();
            begin
                ExportShipments.CreateShopifyFulfillment("Sales Shipment Header");
            end;
        }
    }

    var
        ExportShipments: Codeunit "Shpfy Export Shipments";
}