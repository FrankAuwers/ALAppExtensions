codeunit 139604 "Shpfy Product Mapping Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        LibraryAssert: Codeunit "Library Assert";

    [Test]
    procedure UnitTestFindMappingWithNoSKUMapping()
    var
        Item: Record Item;
        ItemReference: Record "Item Reference";
        Shop: Record "Shpfy Shop";
        ShopifyProduct: Record "Shpfy Product";
        ShopifyVariant: Record "Shpfy Variant";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
        ProductMapping: Codeunit "Shpfy Product Mapping";
        Barcode: Code[50];
    begin
        // [SCENARIO] Shopify product to an item and with the SKU empty.
        // [SCENARIO] Because there is no SKU mapping, it will try to find the mapping based on the bar code field on the Shopify Variant record.
        Shop := InitializeTest.CreateShop();
        Shop."SKU Mapping" := "Shpfy SKU Mappging"::" ";
        Shop.Modify();
        Item := ProductInitTest.CreateItem();
        ItemReference.SetRange("Item No.", Item."No.");
        ItemReference.SetRange("Reference Type", "Item Reference Type"::"Bar Code");
        if ItemReference.FindFirst() then
            BarCode := ItemReference."Reference No.";

        // [GIVEN] A Shopify Product Record
        // [GIVEN] A Shopify Variant record that belongs to the Shopify Product record and has the same barcode of that from the item record.
        ShopifyVariant := ProductInitTest.CreateStandardProduct(Shop);
        ShopifyVariant.Barcode := Barcode;
        ShopifyVariant.Modify();
        ShopifyProduct.Get(ShopifyVariant."Product Id");

        // [WHEN] Invoke ShpfyProductMapping.FindMapping(ShpfyProduct, ShpfyVariant)
        ProductMapping.FindMapping(ShopifyProduct, ShopifyVariant);

        // [THEN] ShpfyVariant."Item SystemId" = Item.SystemId
        LibraryAssert.AreEqual(Item.SystemId, ShopifyVariant."Item SystemId", 'ShpfyVariant."Item SystemId" = Item.SystemId');

        // [THEN] ShpfyProduct."Item SystemId"= Item.SystemId
        LibraryAssert.AreEqual(Item.SystemId, ShopifyProduct."Item SystemId", 'ShpfyProduct."Item SystemId"= Item.SystemId');
    end;

    [Test]
    procedure UnitTestFindMappingWithSKUMappedToItemNo()
    var
        Item: Record Item;
        Shop: Record "Shpfy Shop";
        ShopifyProduct: Record "Shpfy Product";
        ShopifyVariant: Record "Shpfy Variant";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
        ProductMapping: Codeunit "Shpfy Product Mapping";
    begin
        // [SCENARIO] Shopify product to an item and with the SKU mapped to Item No.
        // [SCENARIO] Because there is no SKU mapping, it will try to find the mapping based on the bar code field on the Shopify Variant record.
        Shop := InitializeTest.CreateShop();
        Shop."SKU Mapping" := "Shpfy SKU Mappging"::"Item No.";
        Shop.Modify();
        Item := ProductInitTest.CreateItem();
        ShopifyVariant := ProductInitTest.CreateStandardProduct(Shop);
        ShopifyVariant.SKU := Item."No.";
        ShopifyVariant.Modify();
        ShopifyProduct.Get(ShopifyVariant."Product Id");

        // [GIVEN] A Shopify Product Record
        // [GIVEN] A Shopify Variant record that belongs to the Shopify Product record and has SKU filled in with the item no.
        ProductMapping.FindMapping(ShopifyProduct, ShopifyVariant);

        // [THEN] ShpfyVariant."Item SystemId" = Item.SystemId
        LibraryAssert.AreEqual(Item.SystemId, ShopifyVariant."Item SystemId", 'ShpfyVariant."Item SystemId" = Item.SystemId');

        // [THEN] ShpfyProduct."Item SystemId"= Item.SystemId
        LibraryAssert.AreEqual(Item.SystemId, ShopifyProduct."Item SystemId", 'ShpfyProduct."Item SystemId"= Item.SystemId');
    end;

    [Test]
    procedure UnitTestFindMappingWithSKUMappedToVariantCode()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        Shop: Record "Shpfy Shop";
        ShopifyProduct: Record "Shpfy Product";
        ShopifyVariant: Record "Shpfy Variant";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
        ProductMapping: Codeunit "Shpfy Product Mapping";
    begin
        // [SCENARIO] Shopify product to an item and with the SKU mapped to Variant Code.
        // [SCENARIO] Because there is no SKU mapping, it will try to find the mapping based on the bar code field on the Shopify Variant record.
        Shop := InitializeTest.CreateShop();
        Shop."SKU Mapping" := "Shpfy SKU Mappging"::"Variant Code";
        Shop.Modify();
        Item := ProductInitTest.CreateItem(true);
        ItemVariant.SetRange("Item No.", Item."No.");
        ItemVariant.FindFirst();
        ShopifyVariant := ProductInitTest.CreateStandardProduct(Shop);
        ShopifyVariant.SKU := ItemVariant.Code;
        ShopifyVariant.Modify();
        ShopifyProduct.Get(ShopifyVariant."Product Id");

        // [GIVEN] A Shopify Product Record
        // [GIVEN] A Shopify Variant record that belongs to the Shopify Product record and has SKU filled in with the variant code of a variant of item.
        ProductMapping.FindMapping(ShopifyProduct, ShopifyVariant);

        // [THEN] ShpfyVariant."Item SystemId" = Item.SystemId
        LibraryAssert.AreEqual(Item.SystemId, ShopifyVariant."Item SystemId", 'ShpfyVariant."Item SystemId" = Item.SystemId');

        // [THEN] ShpfyVariant."Item Variant SystemId" = ItemVariant.SystemId
        LibraryAssert.AreEqual(ItemVariant.SystemId, ShopifyVariant."Item Variant SystemId", 'ShpfyVariant."Item Variant SystemId" = ItemVariant.SystemId');

        // [THEN] ShpfyProduct."Item SystemId"= Item.SystemId
        LibraryAssert.AreEqual(Item.SystemId, ShopifyProduct."Item SystemId", 'ShpfyProduct."Item SystemId"= Item.SystemId');
    end;

    [Test]
    procedure UnitTestFindMappingWithSKUMappedToItemNoAndVariantCode()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        yShop: Record "Shpfy Shop";
        ShopifyProduct: Record "Shpfy Product";
        ShopifyVariant: Record "Shpfy Variant";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
        ProductMapping: Codeunit "Shpfy Product Mapping";
    begin
        // [SCENARIO] Shopify product to an item and with the SKU mapped to Item No. + Variant Code.
        // [SCENARIO] Because there is no SKU mapping, it will try to find the mapping based on the bar code field on the Shopify Variant record.
        yShop := InitializeTest.CreateShop();
        yShop."SKU Mapping" := "Shpfy SKU Mappging"::"Item No. + Variant Code";
        yShop.Modify();
        Item := ProductInitTest.CreateItem(true);
        ItemVariant.SetRange("Item No.", Item."No.");
        ItemVariant.FindFirst();
        ShopifyVariant := ProductInitTest.CreateStandardProduct(yShop);
        ShopifyVariant.SKU := Item."No." + yShop."SKU Field Separator" + ItemVariant.Code;
        ShopifyVariant.Modify();
        ShopifyProduct.Get(ShopifyVariant."Product Id");

        // [GIVEN] A Shopify Product Record
        // [GIVEN] A Shopify Variant record that belongs to the Shopify Product record and has SKU filled in with the item.no. + variant code of a variant of item.
        ProductMapping.FindMapping(ShopifyProduct, ShopifyVariant);

        // [THEN] ShpfyVariant."Item SystemId" = Item.SystemId
        LibraryAssert.AreEqual(Item.SystemId, ShopifyVariant."Item SystemId", 'ShpfyVariant."Item SystemId" = Item.SystemId');

        // [THEN] ShpfyVariant."Item Variant SystemId" = ItemVariant.SystemId
        LibraryAssert.AreEqual(ItemVariant.SystemId, ShopifyVariant."Item Variant SystemId", 'ShpfyVariant."Item Variant SystemId" = ItemVariant.SystemId');

        // [THEN] ShpfyProduct."Item SystemId"= Item.SystemId
        LibraryAssert.AreEqual(Item.SystemId, ShopifyProduct."Item SystemId", 'ShpfyProduct."Item SystemId"= Item.SystemId');
    end;

    [Test]
    procedure UnitTestFindMappingWithSKUMappedToVendorItemNo()
    var
        Item: Record Item;
        Shop: Record "Shpfy Shop";
        ShopifyProduct: Record "Shpfy Product";
        ShopifyVariant: Record "Shpfy Variant";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
        ProductMapping: Codeunit "Shpfy Product Mapping";
    begin
        // [SCENARIO] Shopify product to an item and with the SKU mapped to Vendor Item No.
        // [SCENARIO] Because there is no SKU mapping, it will try to find the mapping based on the vendor and SKU field.
        Shop := InitializeTest.CreateShop();
        Shop."SKU Mapping" := "Shpfy SKU Mappging"::"Vendor Item No.";
        Shop.Modify();
        Item := ProductInitTest.CreateItem();
        ShopifyVariant := ProductInitTest.CreateStandardProduct(Shop);
        ShopifyVariant.SKU := Item."Vendor Item No.";
        ShopifyVariant.Modify();
        ShopifyProduct.Get(ShopifyVariant."Product Id");
        ShopifyProduct.Vendor := Item."Vendor No.";
        ShopifyProduct.Modify();

        // [GIVEN] A Shopify Product Record
        // [GIVEN] A Shopify Variant record that belongs to the Shopify Product record and has SKU filled in with the vendor item no.
        ProductMapping.FindMapping(ShopifyProduct, ShopifyVariant);

        // [THEN] ShpfyVariant."Item SystemId" = Item.SystemId
        LibraryAssert.AreEqual(Item.SystemId, ShopifyVariant."Item SystemId", 'ShpfyVariant."Item SystemId" = Item.SystemId');

        // [THEN] ShpfyProduct."Item SystemId"= Item.SystemId
        LibraryAssert.AreEqual(Item.SystemId, ShopifyProduct."Item SystemId", 'ShpfyProduct."Item SystemId"= Item.SystemId');
    end;

    [Test]
    procedure UnitTestFindMappingWithSKUMappedToBarCode()
    var
        Item: Record Item;
        ItemReference: Record "Item Reference";
        Shop: Record "Shpfy Shop";
        ShopifyProduct: Record "Shpfy Product";
        ShopifyVariant: Record "Shpfy Variant";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
        ProductMapping: Codeunit "Shpfy Product Mapping";
        Barcode: Code[50];
    begin
        // [SCENARIO] Shopify product to an item and with the SKU empty.
        // [SCENARIO] Because there is no SKU mapping, it will try to find the mapping based on the bar code in the SKU field on the Shopify Variant record.
        Shop := InitializeTest.CreateShop();
        Shop."SKU Mapping" := "Shpfy SKU Mappging"::"Bar Code";
        Shop.Modify();
        Item := ProductInitTest.CreateItem();
        ItemReference.SetRange("Item No.", Item."No.");
        ItemReference.SetRange("Reference Type", "Item Reference Type"::"Bar Code");
        if ItemReference.FindFirst() then
            BarCode := ItemReference."Reference No.";

        // [GIVEN] A Shopify Product Record
        // [GIVEN] A Shopify Variant record that belongs to the Shopify Product record and has the same barcode of that from the item record.
        ShopifyVariant := ProductInitTest.CreateStandardProduct(Shop);
        ShopifyVariant.SKU := Barcode;
        ShopifyVariant.Modify();
        ShopifyProduct.Get(ShopifyVariant."Product Id");

        // [WHEN] Invoke ShpfyProductMapping.FindMapping(ShpfyProduct, ShpfyVariant)
        ProductMapping.FindMapping(ShopifyProduct, ShopifyVariant);

        // [THEN] ShpfyVariant."Item SystemId" = Item.SystemId
        LibraryAssert.AreEqual(Item.SystemId, ShopifyVariant."Item SystemId", 'ShpfyVariant."Item SystemId" = Item.SystemId');

        // [THEN] ShpfyProduct."Item SystemId"= Item.SystemId
        LibraryAssert.AreEqual(Item.SystemId, ShopifyProduct."Item SystemId", 'ShpfyProduct."Item SystemId"= Item.SystemId');
    end;
}