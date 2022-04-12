/// <summary>
/// Unknown Shpfy PErmissions (ID 30100).
/// </summary>
permissionset 30100 "Shpfy Permisions"
{
    Assignable = true;
    Caption = 'Shopify', MaxLength = 30;

    Permissions =
        table "Shpfy Credit Card Company" = X,
        tabledata "Shpfy Credit Card Company" = RMID,
        table "Shpfy Cue" = X,
        tabledata "Shpfy Cue" = RMID,
        table "Shpfy Customer" = X,
        tabledata "Shpfy Customer" = RMID,
        table "Shpfy Customer Address" = X,
        tabledata "Shpfy Customer Address" = RMID,
        table "Shpfy Customer Template" = X,
        tabledata "Shpfy Customer Template" = RMID,
        table "Shpfy Data Capture" = X,
        tabledata "Shpfy Data Capture" = RMID,
        table "Shpfy Gift Card" = X,
        tabledata "Shpfy Gift Card" = RMID,
        table "Shpfy Inventory Item" = X,
        tabledata "Shpfy Inventory Item" = RMID,
        table "Shpfy Log Entry" = X,
        tabledata "Shpfy Log Entry" = RMID,
        table "Shpfy Metafield" = X,
        tabledata "Shpfy Metafield" = RMID,
        table "Shpfy Order Attribute" = X,
        tabledata "Shpfy Order Attribute" = RMID,
        table "Shpfy Order Disc.Appl." = X,
        tabledata "Shpfy Order Disc.Appl." = RMID,
        table "Shpfy Order Fulfillment" = X,
        tabledata "Shpfy Order Fulfillment" = RMID,
        table "Shpfy Order Header" = X,
        tabledata "Shpfy Order Header" = RMID,
        table "Shpfy Order Line" = X,
        tabledata "Shpfy Order Line" = RMID,
        table "Shpfy Order Payment Gateway" = X,
        tabledata "Shpfy Order Payment Gateway" = RMID,
        table "Shpfy Order Risk" = X,
        tabledata "Shpfy Order Risk" = RMID,
        table "Shpfy Order Shipping Cost" = X,
        tabledata "Shpfy Order Shipping Cost" = RMID,
        table "Shpfy Orders To Import" = X,
        tabledata "Shpfy Orders To Import" = RMID,
        table "Shpfy Order Tax Line" = X,
        tabledata "Shpfy Order Tax Line" = RMID,
        table "Shpfy Order Transaction" = X,
        tabledata "Shpfy Order Transaction" = RMID,
        table "Shpfy Payment Method Mapping" = X,
        tabledata "Shpfy Payment Method Mapping" = RMID,
        table "Shpfy Payment Transaction" = X,
        tabledata "Shpfy Payment Transaction" = RMID,
        table "Shpfy Payout" = X,
        tabledata "Shpfy Payout" = RMID,
        table "Shpfy Product" = X,
        tabledata "Shpfy Product" = RMID,
        table "Shpfy Province" = X,
        tabledata "Shpfy Province" = RMID,
        table "Shpfy Registered Store" = X,
        tabledata "Shpfy Registered Store" = RMID,
        table "Shpfy Shipment Method" = X,
        tabledata "Shpfy Shipment Method" = RMID,
        table "Shpfy Shop" = X,
        tabledata "Shpfy Shop" = RMID,
        table "Shpfy Shop Collection Map" = X,
        tabledata "Shpfy Shop Collection Map" = RMID,
        table "Shpfy Shop Inventory" = X,
        tabledata "Shpfy Shop Inventory" = RMID,
        table "Shpfy Shop Location" = X,
        tabledata "Shpfy Shop Location" = RMID,
        table "Shpfy Synchronization Info" = X,
        tabledata "Shpfy Synchronization Info" = RMID,
        table "Shpfy Tag" = X,
        tabledata "Shpfy Tag" = RMID,
        table "Shpfy Tax Area" = X,
        tabledata "Shpfy Tax Area" = RMID,
        table "Shpfy Transaction Gateway" = X,
        tabledata "Shpfy Transaction Gateway" = RMID,
        table "Shpfy Variant" = X,
        tabledata "Shpfy Variant" = RMID,
        codeunit "Shpfy Authentication Mgt." = X,
        codeunit "Shpfy Background Syncs" = X,
        codeunit "Shpfy Base64" = X,
        codeunit "Shpfy Communication Events" = X,
        codeunit "Shpfy Communication Mgt." = X,
        codeunit "Shpfy County Code" = X,
        codeunit "Shpfy County Name" = X,
        codeunit "Shpfy Create Customer" = X,
        codeunit "Shpfy Create Item" = X,
        codeunit "Shpfy CreateProdStatusActive" = X,
        codeunit "Shpfy CreateProdStatusDraft" = X,
        codeunit "Shpfy Create Product" = X,
        codeunit "Shpfy Cust. By Bill-to" = X,
        codeunit "Shpfy Cust. By Default Cust." = X,
        codeunit "Shpfy Cust. By Email/Phone" = X,
        codeunit "Shpfy Customer API" = X,
        codeunit "Shpfy Customer Events" = X,
        codeunit "Shpfy Customer Export" = X,
        codeunit "Shpfy Customer Import" = X,
        codeunit "Shpfy Customer Mapping" = X,
        codeunit "Shpfy Export Shipments" = X,
        codeunit "Shpfy Filter Mgt." = X,
        codeunit "Shpfy Gift Cards" = X,
        codeunit "Shpfy GQL ApiKey" = X,
        codeunit "Shpfy GQL Customer" = X,
        codeunit "Shpfy GQL CustomerIds" = X,
        codeunit "Shpfy GQL FindCustByEMail" = X,
        codeunit "Shpfy GQL FindCustByPhone" = X,
        codeunit "Shpfy GQL FindVariantBySKU" = X,
        codeunit "Shpfy GQL FndVariantByBarcode" = X,
        codeunit "Shpfy GQL InventoryEntries" = X,
        codeunit "Shpfy GQL LocationOrderLines" = X,
        codeunit "Shpfy GQL NextCustomerIds" = X,
        codeunit "Shpfy GQL NextInvEntries" = X,
        codeunit "Shpfy GQL NextOrderFulfillm" = X,
        codeunit "Shpfy GQL NextOrdersToImport" = X,
        codeunit "Shpfy GQL NextProductIds" = X,
        codeunit "Shpfy GQL NextProductImages" = X,
        codeunit "Shpfy GQL NextVariantIds" = X,
        codeunit "Shpfy GQL NextVariantImages" = X,
        codeunit "Shpfy GQL OrderFulfillment" = X,
        codeunit "Shpfy GQL OrderRisks" = X,
        codeunit "Shpfy GQL OrdersToImport" = X,
        codeunit "Shpfy GQL ProductById" = X,
        codeunit "Shpfy GQL ProductIds" = X,
        codeunit "Shpfy GQL ProductImages" = X,
        codeunit "Shpfy GQL UpdateOrderAttr" = X,
        codeunit "Shpfy GQL VariantById" = X,
        codeunit "Shpfy GQL VariantIds" = X,
        codeunit "Shpfy GQL VariantImages" = X,
        codeunit "Shpfy GraphQL Queries" = X,
        codeunit "Shpfy GraphQL Rate Limit" = X,
        codeunit "Shpfy Hash" = X,
        codeunit "Shpfy Import Order" = X,
        codeunit "Shpfy Install Mgt." = X,
        codeunit "Shpfy Inventory API" = X,
        codeunit "Shpfy Inventory Events" = X,
        codeunit "Shpfy Item Reference Mgt." = X,
        codeunit "Shpfy Json Helper" = X,
        codeunit "Shpfy Math" = X,
        codeunit "Shpfy Name = ''" = X,
        codeunit "Shpfy Name = CompanyName" = X,
        codeunit "Shpfy Name = First. LastName" = X,
        codeunit "Shpfy Name = Last. FirstName" = X,
        codeunit "Shpfy Order Events" = X,
        codeunit "Shpfy Order Fulfillments" = X,
        codeunit "Shpfy Order Mapping" = X,
        codeunit "Shpfy Order Mgt." = X,
        codeunit "Shpfy Order Risks" = X,
        codeunit "Shpfy Orders API" = X,
        codeunit "Shpfy Payments" = X,
        codeunit "Shpfy Process Order" = X,
        codeunit "Shpfy Process Orders" = X,
        codeunit "Shpfy Product API" = X,
        codeunit "Shpfy Product Events" = X,
        codeunit "Shpfy Product Export" = X,
        codeunit "Shpfy Product Image Export" = X,
        codeunit "Shpfy Product Import" = X,
        codeunit "Shpfy Product Mapping" = X,
        codeunit "Shpfy Product Price Calc." = X,
        codeunit "Shpfy RemoveProductDoNothing" = X,
        codeunit "Shpfy REST Client" = X,
        codeunit "Shpfy Shipping Costs" = X,
        codeunit "Shpfy Shipping Events" = X,
        codeunit "Shpfy Shipping Methods" = X,
        codeunit "Shpfy Sync Countries" = X,
        codeunit "Shpfy Sync Customers" = X,
        codeunit "Shpfy Sync Inventory" = X,
        codeunit "Shpfy Sync Orders" = X,
        codeunit "Shpfy Sync Product Image" = X,
        codeunit "Shpfy Sync Products" = X,
        codeunit "Shpfy Sync Shop Locations" = X,
        codeunit "Shpfy ToArchivedProduct" = X,
        codeunit "Shpfy ToDraftProduct" = X,
        codeunit "Shpfy Transactions" = X,
        codeunit "Shpfy Update Customer" = X,
        codeunit "Shpfy Update Item" = X,
        codeunit "Shpfy Upgrade Mgt." = X,
        codeunit "Shpfy Variant API" = X,
        page "Shpfy Activities" = X,
        page "Shpfy Authentication" = X,
        page "Shpfy Credit Card Companies" = X,
        page "Shpfy Customer Adresses" = X,
        page "Shpfy Customer Card" = X,
        page "Shpfy Customers" = X,
        page "Shpfy Customer Templates" = X,
        page "Shpfy Data Capture List" = X,
        page "Shpfy Gift Cards" = X,
        page "Shpfy Gift Card Transactions" = X,
        page "Shpfy Inventory FactBox" = X,
        page "Shpfy Log Entries" = X,
        page "Shpfy Log Entry Card" = X,
        page "Shpfy Order" = X,
        page "Shpfy Order Attributes" = X,
        page "Shpfy Order Fulfillments" = X,
        page "Shpfy Order Risks" = X,
        page "Shpfy Orders" = X,
        page "Shpfy Order Shipping Costs" = X,
        page "Shpfy Orders To Import" = X,
        page "Shpfy Order Subform" = X,
        page "Shpfy Order Transactions" = X,
        page "Shpfy Payment Methods" = X,
        page "Shpfy Payment Transactions" = X,
        page "Shpfy Payouts" = X,
        page "Shpfy Products" = X,
        page "Shpfy Shipment Methods" = X,
        page "Shpfy Shop Card" = X,
        page "Shpfy Shop Locations" = X,
        page "Shpfy Shops" = X,
        page "Shpfy Tag Factbox" = X,
        page "Shpfy Tags" = X,
        page "Shpfy Tax Areas" = X,
        page "Shpfy Transaction Gateways" = X,
        page "Shpfy Transactions" = X,
        page "Shpfy Variants" = X,
        query "Shpfy Shipment Location" = X,
        report "Shpfy Add Item to Shopify" = X,
        report "Shpfy Create Location Filter" = X,
        report "Shpfy Create Sales Orders" = X,
        report "Shpfy Sync Customers" = X,
        report "Shpfy Sync Images" = X,
        report "Shpfy Sync Orders from Shopify" = X,
        report "Shpfy Sync Payments" = X,
        report "Shpfy Sync Products" = X,
        report "Shpfy Sync Shipm. To Shopify" = X,
        report "Shpfy Sync Stock To Shopify" = X;
}