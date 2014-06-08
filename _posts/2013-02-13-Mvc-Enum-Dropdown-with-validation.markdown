---
layout: post
title: Mvc Enum Dropdown with validation
categories: asp.net mvc

---

A very frequent question I see is how to make working with dropdown lists easy. Most of the solutions you can find involve a quick and dirty approach. I say dirty because it appears to solve the problem, but really leaves you without server validation.

Sure you can pass a SelectList to your view through the ViewBag or a property on the model, but it really only solves half the problem. An ideal solution is hidden from your view and controller and requires only decorating your model with an attribute.

{% prism csharp %}
public class ModelWithEnumField
{
    [EnumDropDown(typeof(Status))]
    public Status CurrentStatus { get; set; }
}
{% endprism %}

Providing the available options for the dropdown and the validation can be handled within the attribute using the enum's type for its possible values. This could also be easily extended to have separate text for the SelectListItem Text and Value properties, using attributes on the enum itself.

{% prism csharp %}
[AttributeUsage(AttributeTargets.Property)]
public class EnumDropDownAttribute : ValidationAttribute, IMetadataAware
{
    public Type EnumType { get; set; }

    public EnumDropDownAttribute(Type enumType)
    {
        EnumType = enumType;
        ErrorMessage = "The submitted value for {0} was not in the list of expected options";
    }

    public void OnMetadataCreated(ModelMetadata metadata)
    {
        metadata.TemplateHint = "EnumDropdown";
        var selectItems = GetValues()
            .Select(x => new SelectListItem
                             {
                                 Text = x,
                                 Value = x
                             });
        metadata.AdditionalValues["EnumValues"] = selectItems;
    }

    private IEnumerable<string> GetValues()
    {
        return Enum
            .GetValues(EnumType)
            .Cast<object>()
            .Select(x => x.ToString());
    } 

    public override bool IsValid(object value)
    {
        if (value == null || !(value is string))
            return true;
        return GetValues().Any(x => x == value as string);
    }
}
{% endprism %}

Above, I inherit from the ValidationAttribute so that I get server model validation without additional code in my controller. I could also use a string for the property type on my model and it would be validated just the same. The IMetadataAware interface ensures that my attribute will be called to provide meta data before the model's view is selected. The TemplateHint property basically does the same thing as either of the following.

{% prism csharp %}
[DataType("EnumDropdown")]
[UIHint("EnumDropdown")]
@Html.EditorFor(m=>m.CurrentStatus,"EditorTemplates/EnumDropdown")
{% endprism %}

And finally, I create a generic dropdown list template under Views\Shared\EditorTemplates\EnumDropdown.cshtml

{% prism csharp %}
@model object
@{
    var values = (ViewData.ModelMetadata.AdditionalValues["EnumValues"] as IEnumerable<SelectListItem>);
}
@Html.DropDownListFor(m => m, values)
{% endprism %}