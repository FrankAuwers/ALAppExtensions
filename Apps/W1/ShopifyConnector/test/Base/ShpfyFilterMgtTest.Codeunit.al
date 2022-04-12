/// <summary>
/// Codeunit Shpfy Filter Mgt. Test (ID 30505).
/// </summary>
codeunit 30505 "Shpfy Filter Mgt. Test"
{
    Subtype = Test;

    var
        Any: Codeunit Any;
        Assert: Codeunit "Library Assert";

    [Test]
    procedure UnitTestCleanFilterValue()
    var
        TestFields: Record "Shpfy Test Fields";
        FilterMgt: Codeunit "Shpfy Filter Mgt.";
        Index: Integer;
        InvalidCharsTxt: Label '()*.<>=', Locked = true;
        SearchStrings: List of [Text];
    begin
        // Creating Test data.
        For Index := 1 to StrLen(Format(InvalidCharsTxt)) do begin
            TestFields.BigIntegerField := Index;
            TestFields.TextField := Any.AlphabeticText(5 + Index) + Format(InvalidCharsTxt) [Index] + Any.AlphabeticText(3);
            TestFields.Insert();
        end;

        // [SCENARIO] Create for every record a searchstring with the function CleanFilterValue
        //            and try to find this record based on the created searchstring.
        //            the result must be that 1 record is found.

        // [GIVEN] Textfield to convert for creating a search string.
        if TestFields.FindSet(false, false) then
            repeat
                SearchStrings.Add(FilterMgt.CleanFilterValue(TestFields.TextField));
            until TestFields.Next() = 0;

        // [WHEN] filtering on a searchstring 
        // [THEN] this must give a result of 1 record back.
        for Index := 1 to SearchStrings.Count do begin
            TestFields.SetFilter(TextField, SearchStrings.Get(Index));
            Assert.RecordCount(TestFields, 1);
        end;
    end;
}