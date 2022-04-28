/// <summary>
/// Codeunit Shpfy Create Customer Test (ID 30509).
/// </summary>
codeunit 30509 "Shpfy Create Customer Test"
{
    Subtype = Test;
    EventSubscriberInstance = Manual;

    var
        Assert: Codeunit "Library Assert";
        CommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        This: Codeunit "Shpfy Create Customer Test";
        CustomerInitTest: Codeunit "Shpfy Customer Init Test";
        OnCreateCustomerEventMsg: Label 'OnCreateCustomer', Locked = true;

    [Test]
    [HandlerFunctions('OnCreateCustomerHandler')]
    procedure UniTestCreateCustomerFromShopifyInfo()
    var
        ConfigTemplateHeader: Record "Config. Template Header";
        Customer: Record Customer;
        ShpfyCustomerAddress: Record "Shpfy Customer Address";
        ShpfyCreateCustomer: Codeunit "Shpfy Create Customer";
    begin
        // Creating Test data. The database must have a Config Template for creating a customer.
        Init();
        ShpfyCreateCustomer.SetShop(CommunicationMgt.GetShopRecord());
        ConfigTemplateHeader.SetRange("Table ID", Database::Customer);
        if not ConfigTemplateHeader.FindFirst() then
            exit;

        // [SCENARIO] Create a customer from an new Shopify Customer Address.
        ShpfyCustomerAddress := CustomerInitTest.CreateShopifyCustomerAddress();
        ShpfyCustomerAddress.SetRecFilter();

        // [GIVEN] The shop
        ShpfyCreateCustomer.SetShop(CommunicationMgt.GetShopRecord());
        // [GIVEN] The customer template code
        ShpfyCreateCustomer.SetTemplateCode(ConfigTemplateHeader.Code);
        // [GIVEN] The Shopify Customer Address record.
        BindSubscription(This);
        ShpfyCreateCustomer.Run(ShpfyCustomerAddress);
        UnbindSubscription(This);
        // [THEN] The customer record can be found by the link of CustomerSystemId.
        ShpfyCustomerAddress.Get(ShpfyCustomerAddress.Id);
        if not Customer.GetBySystemId(ShpfyCustomerAddress.CustomerSystemId) then
            Assert.AssertRecordNotFound();
    end;

    local procedure Init()
    var
        Shop: Record "Shpfy Shop";
    begin
        Codeunit.Run(Codeunit::"Shpfy Initialize Test");
        Shop := CommunicationMgt.GetShopRecord();
        if Shop."Default Customer No." = '' then begin
            Shop."Name Source" := "Shpfy Name Source"::CompanyName;
            Shop."Name 2 Source" := "Shpfy Name Source"::FirstAndLastName;
            if not Shop.Modify(false) then
                Shop.Insert();
            CommunicationMgt.SetShop(Shop);
        end;
    end;

    [MessageHandler]
    procedure OnCreateCustomerHandler(Message: Text)
    begin
        Assert.ExpectedMessage(OnCreateCustomerEventMsg, Message);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Shpfy Customer Events", 'OnBeforeCreateCustomer', '', true, false)]
    local procedure OnBeforeCreateCustomer()
    begin
        Message(OnCreateCustomerEventMsg);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Shpfy Customer Events", 'OnAfterCreateCustomer', '', true, false)]
    local procedure OnAfterCreateCustomer()
    begin
        Message(OnCreateCustomerEventMsg);
    end;
}
