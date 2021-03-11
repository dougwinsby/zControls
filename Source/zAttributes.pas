// **************************************************************************************************
// The contents of this file are subject to the Mozilla Public License Version 1.1 (the "License");
// you may not use this file except in compliance with the License. You may obtain a copy of the
// License at http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF
// ANY KIND, either express or implied. See the License for the specific language governing rights
// and limitations under the License.
//
// The Original Code is zAttributes.pas.
//
// The Initial Developer of the Original Code is Doug Winsby (dougwinsby on github).
// Portions created by Doug Winsby are Copyright (C) 2021 Doug Winsby.
// All Rights Reserved.
//
// **************************************************************************************************

// **************************************************************************************************
// https://github.com/dougwinsby/zcontrols
// (contributed to https://github.com/MahdiSafsafi/zcontrols)
// ************************************************************************************************** 

// Purpose:
//   Add custom attribute support
//
// Description:
//   Allow users to decorate properties with custom attributs (declaritively) instead of through api.
//
// Supported Attributes
//   [Name('value')] - Displays a friendly property name for the user
//   [Category('name')] - Groups the properties by these category names
//   [Hint('value')] - Exposes description to UI through events (PItem^.AttrHint)
//   [StripPrefix('value')] - Will remove enum prefixes from ValueName when displayed
//   [ReadOnlyProp] - Treats the property as readonly, even if a writer available.

unit zAttributes;

interface

uses
  system.classes,
  RTTI;

type

{$region '** Custom Attributes **')}

  // [ReadOnlyProp] (you might need a setter for serialization, but also want it read-only)
  ReadOnlyPropAttribute = class(TCustomAttribute);

  // [Category('text')]
  CategoryAttribute = class(TCustomAttribute)
  private
    FName: string;
  public
    constructor Create(const Value: string);
    property Name: string read FName;
  end;

  // [Name('text')] (grab it with OnGetItemFriendlyName)
  NameAttribute = class(TCustomAttribute)
  private
    FName: string;
  public
    constructor Create(const Value: string);
    property Name: string read FName;
  end;

  // [Hint('text')] (not a normal hint... grab it with OnSelectItem or similar for UI display)
  HintAttribute = class(TCustomAttribute)
  private
    FHintText: string;
  public
    constructor Create(const Value: string);
    property HintText: string read FHintText;
  end;

  // [StripPrefix('text')]
  StripPrefixAttribute = class(TCustomAttribute)
  private
    FPrefix: string;
  public
    constructor Create(const Value: string);
    property Prefix: string read FPrefix;
  end;

{$endregion}

  // TPropAttrs is included in each TPropItem
  TPropAttrs = record
    Loaded: boolean;
    AttrReadOnly: boolean;    // [ReadOnlyProp]
    AttrCategory: string;     // [Category('value')]
    AttrName: string;         // [Name('value')]
    AttrHint: string;         // [Hint('value')]
    AttrStripPrefix: string;  // [StripPrefix('value')]
  end;

  // External visibility
  function GetCustomAttributes(const Prop: TRttiProperty): TPropAttrs;

implementation

function GetCustomAttributes(const Prop: TRttiProperty): TPropAttrs;
var
  attr: TCustomAttribute;
begin
  Assert(Assigned(Prop), 'Attempted to get custom atributes of a nil property');

  // initialize results
  result.Loaded := true;
  result.AttrReadOnly := false;
  result.AttrCategory := '';
  result.AttrName := '';
  result.AttrHint := '';
  result.AttrStripPrefix := '';

  // iterate attributes looking for our custom ones
  for attr in Prop.GetAttributes do
  begin
    if attr is ReadOnlyPropAttribute then result.AttrReadOnly := true else
    if attr is CategoryAttribute     then result.AttrCategory := CategoryAttribute(attr).Name else
    if attr is HintAttribute         then result.AttrHint := HintAttribute(attr).HintText else
    if attr is NameAttribute         then result.AttrName := NameAttribute(attr).Name else
    if attr is StripPrefixAttribute  then result.AttrStripPrefix := StripPrefixAttribute(attr).Prefix;
  end;
end;

{ CategoryAttribute }

constructor CategoryAttribute.Create(const Value: string);
begin
  FName := Value;
end;

{ NameAttribute }

constructor NameAttribute.Create(const Value: string);
begin
  FName := Value;
end;

{ HintAttribute }

constructor HintAttribute.Create(const Value: string);
begin
  FHintText := Value;
end;

{ StripPrefixAttribute }

constructor StripPrefixAttribute.Create(const Value: string);
begin
  FPrefix := Value;
end;

end.

