/// <summary>
/// Page Shpfy Customer Adresses (ID 30105).
/// </summary>
page 30105 "Shpfy Customer Adresses"
{
    Caption = 'Shopify Customer Adrresses';
    Editable = false;
    PageType = ListPart;
    SourceTable = "Shpfy Customer Address";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Id; Rec.Id)
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'The Shopify id of this address record.';
                }
                field(Default; Rec.Default)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the default address for the customer.';
                }
                field(Company; Rec.Company)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the customer''s company.';
                }
                field(FirstName; Rec.FirstName)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the customer''s first name.';
                }
                field(LastName; Rec.LastName)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the customer''s last name.';
                }
                field(Address1; Rec.Address1)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the customer''s address.';
                }
                field(Address2; Rec.Address2)
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the customer''s address 2.';
                }
                field(Zip; Rec.Zip)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the customer''s postal code.';
                }
                field(City; Rec.City)
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the city of the address.';
                }
                field(CountryCode; Rec.CountryCode)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the country/region of the address.';
                }
                field(CountryName; Rec.CountryName)
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the country/region name of the address.';
                }
                field(ProvinceCode; Rec.ProvinceCode)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the customer''s region code. Typically a province, a state or a prefecture.';
                }
                field(ProvinceName; Rec.ProvinceName)
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the customer''s region name. Typically a province, a state or a prefecture.';
                }
                field(Phone; Rec.Phone)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the customer''s phone number at this address.';
                }
            }
        }
    }

}
