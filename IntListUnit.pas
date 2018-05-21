{@abstract(@name defines @link(TIntegerList) which is used to store
 a series of integers and @link(TIntListList) which is used to store
 a series of @link(TIntegerList)s.)}
unit IntListUnit;

interface

uses Classes;

type
    // @abstract(@name acts much like TList except that it stores integers
    // rather than pointers.)
  TIntegerList = class(TObject)
  private
    // @name: TList;
    // @name stores instances of TIntegerClass (defined in the implementation
    // section.  Those instances each store one of the values stored in
    // @classname.
    FList: TList;
    // @name: boolean;
    // @name indicates whether or not the @classname is sorted.
    FSorted: boolean;
    // See @link(Capacity).
    function GetCapacity: integer;
    // See @link(Count).
    function GetCount: integer;
    // See @link(Items).
    function GetItem(Index: integer): integer;
    // See @link(Capacity).
    procedure SetCapacity(ACapacity: Integer);
    // See @link(Items).
    procedure SetItem(Index: integer; const AnInteger: integer);
    // See @link(Sorted).
    procedure SetSorted(AValue: boolean);
  public
    // @name adds AnInteger to the @classname.  If @link(Sorted) is
    // true, @name inserts AnInteger so as to keep the @classname sorted.
    procedure Add(const AnInteger: integer);
    // @name will add AnInteger to the @classname if there isn't already
    // one in the @classname.
    procedure AddUnique(const AnInteger: integer);
    // @name indicates how many integers the @classname can hold without
    // reallocating memory for the list of integers.
    property Capacity: integer read GetCapacity write SetCapacity;
    // @name deletes all the integers from the @classname.
    procedure Clear;
    // @name indicates how many integers are stored in the @classname.
    property Count: integer read GetCount;
    // @name creates an instance of @classname.
    constructor Create;
    // @name deletes the integer at position Index from the list of integers.
    procedure Delete(Index: Integer);
    // @name destroys the current instance of @classname.
    // Do not call @name directly.  Call Free instead.
    destructor Destroy; override;
    // @name raises and EListError exception.
    // See TList.Error.
    class procedure Error(const Msg: string; Data: Integer); virtual;
    // @name switches the integers at positions Index1 and Index2.
    procedure Exchange(Index1, Index2: Integer);
    // @name returns the first integer in the @classname.
    function First: Integer;
    { TODO : See if some of the code in IndexOf can be combined with that in Add. }
    // @name returns the position of AnInteger in the @classname.
    function IndexOf(AnInteger: integer): integer;
    // @name inserts AnInteger into the @classname at position Index.
    procedure Insert(Index: Integer; AnInteger: integer);
    // @name is used to get and retrieve integers by their position in the
    // @classname.
    property Items[Index: integer]: integer read GetItem write SetItem; default;
    // @name gets the last integer in the @classname.
    function Last: integer;
    // @name returns the highest integer in the @classname.
    function MaxValue: integer;
    // @name returns the lowest integer in the @classname.
    function MinValue: integer;
    // @name moves the integer at CurIndex to NewIndex.
    procedure Move(CurIndex, NewIndex: Integer);
    // @name returns the position of the integer in @classname whose
    // value is closest to TestValue.
    function Nearest(const TestValue: integer): integer;
    // @name removes nil pointers from the embedded TList.
    procedure Pack;
    // @name sorts the integers in @classname in ascending order and sets
    // @link(Sorted) to true.
    procedure Sort;
    // @name indicates whether or not the integers in @classname have
    // been sorted in ascending order using Sort.
    property Sorted: boolean read FSorted write SetSorted;
  end;

  // @abstract(@name is a list of @link(TIntegerList)s.)
  // @name does not own the @link(TIntegerList)s.
  TIntListList = class(TObject)
  private
    // @name: TList;
    // @name is an internal TList that holds the @link(TIntegerList)s.
    FList: TList;
    // See @link(Capacity).
    function GetCapacity: integer;
    // See @link(Count).
    function GetCount: integer;
    // See @link(Items).
    function GetItem(Index: integer): TIntegerList;
    // See @link(Capacity).
    procedure SetCapacity(ACapacity: Integer);
    // See @link(Items).
    procedure SetItem(Index: integer; const AnIntList: TIntegerList);
  public
    // @name adds a @link(TIntegerList) to the @classname.
    procedure Add(const AnIntList: TIntegerList);
    // @name is the number of @link(TIntegerList)s the @classname can hold
    // without reallocating memory.
    property Capacity: integer read GetCapacity write SetCapacity;
    // @name removes all @link(TIntegerList)s from @classname.
    procedure Clear;
    // @name is the number of @link(TIntegerList)s in @classname.
    property Count: integer read GetCount;
    // @name creates an instance of @classname.
    constructor Create;
    // @name destroys the current instance of @classname.
    // Do not call @name directly.  Call Free instead.
    destructor Destroy; override;
    // @name returns the position of AnIntList in @classname.  If
    // AnIntList is not in @classname, @name returns -1.
    function IndexOf(AnIntList: TIntegerList): integer;
    // @name provides access to the @link(TIntegerList)s stored in @classname.
    property Items[Index: integer]: TIntegerList read GetItem write SetItem;
      default;
  end;

implementation

type
  TIntegerClass = class(TObject)
  private
    AnInteger: integer;
  end;

constructor TIntegerList.Create;
begin
  inherited;
  { TODO : 
    Maybe FList should be instantiated as a TObjectList.
    Clear would need to be changed.
    Maybe other things too. }
  FList := TList.Create;
  FSorted := False;
end;

destructor TIntegerList.Destroy;
begin
  Clear;
  FList.Free;
  inherited Destroy;
end;

procedure TIntegerList.AddUnique(const AnInteger: integer);
begin
  if IndexOf(AnInteger) = -1 then
  begin
    Add(AnInteger);
  end;
end;

procedure TIntegerList.Add(const AnInteger: integer);
var
  AnIntegerClass: TIntegerClass;
  Top, Bottom, Middle: integer;
begin
  AnIntegerClass := TIntegerClass.Create;
  AnIntegerClass.AnInteger := AnInteger;

  if FSorted then
  begin
    if FList.Count > 0 then
    begin
      if (TIntegerClass(FList.Items[0]).AnInteger > AnInteger) then
      begin
        FList.Insert(0, AnIntegerClass);
      end
      else if (TIntegerClass(FList.Items[FList.Count - 1]).AnInteger < AnInteger)
        then
      begin
        FList.Add(AnIntegerClass);
      end
      else
      begin
        Top := FList.Count - 1;
        Bottom := 0;
        while Top - Bottom > 1 do
        begin
          Middle := (Top + Bottom) div 2;
          if TIntegerClass(FList.Items[Middle]).AnInteger < AnInteger then
          begin
            Bottom := Middle;
          end
          else
          begin
            Top := Middle;
          end;
        end; // While Top - Bottom > 1 do
        FList.Insert(Top, AnIntegerClass);
      end;
    end
    else // if FList.Count > 0 then
    begin
      FList.Add(AnIntegerClass);
    end;
  end
  else // if FSorted then
  begin
    FList.Add(AnIntegerClass);
  end;
end;

procedure TIntegerList.Delete(Index: Integer);
var
  AnIntegerClass: TIntegerClass;
begin
  AnIntegerClass := FList.Items[Index];
  FList.Delete(Index);
  AnIntegerClass.Free;
end;

procedure TIntegerList.Clear;
var
  AnIntegerClass: TIntegerClass;
  index: integer;
begin
  for index := FList.Count - 1 downto 0 do
  begin
    AnIntegerClass := FList.Items[Index];
    AnIntegerClass.Free;
  end;
  FList.Clear;
end;

class procedure TIntegerList.Error(const Msg: string; Data: Integer);
begin
  TList.Error(Msg, Data);
end;

procedure TIntegerList.Exchange(Index1, Index2: Integer);
begin
  FList.Exchange(Index1, Index2);
  FSorted := False;
end;

function TIntegerList.First: Integer;
var
  AnIntegerClass: TIntegerClass;
begin
  AnIntegerClass := FList.First;
  result := AnIntegerClass.AnInteger;
end;

procedure TIntegerList.Insert(Index: Integer; AnInteger: integer);
var
  AnIntegerClass: TIntegerClass;
begin
  AnIntegerClass := TIntegerClass.Create;
  AnIntegerClass.AnInteger := AnInteger;
  FList.Insert(Index, AnIntegerClass);
  FSorted := False;
end;

function TIntegerList.Last: integer;
var
  AnIntegerClass: TIntegerClass;
begin
  AnIntegerClass := FList.Last;
  result := AnIntegerClass.AnInteger;
end;

procedure TIntegerList.Move(CurIndex, NewIndex: Integer);
begin
  { TODO : It looks like this could lead to access violations
  and/or memory leaks. Maybe this procedure should just be deleted.}
  FList.Move(CurIndex, NewIndex);
  FSorted := False;
end;

procedure TIntegerList.Pack;
begin
  { TODO : Is this method needed? Maybe it should be deleted. }
  FList.Pack
end;

procedure TIntegerList.SetItem(Index: integer; const AnInteger: integer);
var
  AnIntegerClass: TIntegerClass;
begin
  AnIntegerClass := FList.Items[Index];
  if not (AnIntegerClass.AnInteger = AnInteger) then
  begin
    AnIntegerClass.AnInteger := AnInteger;
    FSorted := False;
  end;
end;

function TIntegerList.GetItem(Index: integer): integer;
var
  AnIntegerClass: TIntegerClass;
begin
  AnIntegerClass := FList.Items[Index];
  result := AnIntegerClass.AnInteger;
end;

function TIntegerList.GetCount: integer;
begin
  result := FList.Count
end;

procedure TIntegerList.SetCapacity(ACapacity: Integer);
begin
  if not (FList.Capacity = ACapacity) then
  begin
    FList.Capacity := ACapacity
  end;
end;

function TIntegerList.GetCapacity: integer;
begin
  result := FList.Capacity
end;

function SortFunction(Item1, Item2: Pointer): Integer;
var
  Int1, Int2: TIntegerClass;
begin
  Int1 := TIntegerClass(Item1);
  Int2 := TIntegerClass(Item2);
  if Int1.AnInteger < Int2.AnInteger then
  begin
    result := -1;
  end
  else if Int1.AnInteger = Int2.AnInteger then
  begin
    result := 0;
  end
  else
  begin
    result := 1;
  end;
end;

procedure TIntegerList.Sort;
begin
  FList.Sort(SortFunction);
  FSorted := True;
end;

function TIntegerList.IndexOf(AnInteger: integer): integer;
var
  Index, Top, Bottom, Middle: integer;
begin
  if FSorted then
  begin
    if FList.Count = 0 then
    begin
      result := -1;
    end
    else
    begin
      if (TIntegerClass(FList.Items[0]).AnInteger > AnInteger) or
        (TIntegerClass(FList.Items[FList.Count - 1]).AnInteger < AnInteger) then
      begin
        result := -1;
      end
      else
      begin
        Top := FList.Count - 1;
        Bottom := 0;
        while Top - Bottom > 1 do
        begin
          Middle := (Top + Bottom) div 2;
          if TIntegerClass(FList.Items[Middle]).AnInteger < AnInteger then
          begin
            Bottom := Middle;
          end
          else
          begin
            Top := Middle;
          end;
        end; // While Top - Bottom > 1 do
        if TIntegerClass(FList.Items[Bottom]).AnInteger = AnInteger then
        begin
          result := Bottom;
        end
        else if TIntegerClass(FList.Items[Top]).AnInteger = AnInteger then
        begin
          result := Top;
        end
        else
        begin
          result := -1;

        end;
      end;
    end;
  end
  else
  begin
    result := -1;
    for Index := 0 to FList.Count - 1 do
    begin
      if TIntegerClass(FList.Items[Index]).AnInteger = AnInteger then
      begin
        result := Index;
        break;
      end;
    end;
  end;
end;

{ TIntListList }

procedure TIntListList.Add(const AnIntList: TIntegerList);
begin
  FList.Add(AnIntList);
end;

procedure TIntListList.Clear;
begin
  FList.Clear;
end;

constructor TIntListList.Create;
begin
  inherited;
  FList := TList.Create;
end;

destructor TIntListList.Destroy;
begin
  FList.Free;
  inherited Destroy;
end;

function TIntListList.GetCapacity: integer;
begin
  result := FList.Capacity;
end;

function TIntListList.GetCount: integer;
begin
  result := FList.Count;
end;

function TIntListList.GetItem(Index: integer): TIntegerList;
begin
  Result := FList[Index];
end;

function TIntListList.IndexOf(AnIntList: TIntegerList): integer;
begin
  result := FList.IndexOf(AnIntList);
end;

procedure TIntListList.SetCapacity(ACapacity: Integer);
begin
  FList.Capacity := ACapacity;
end;

procedure TIntListList.SetItem(Index: integer;
  const AnIntList: TIntegerList);
begin
  FList[Index] := AnIntList;
end;

procedure TIntegerList.SetSorted(AValue: boolean);
begin
  if AValue then
  begin
    if not FSorted then
    begin
      Sort;
    end;
  end
  else
  begin
    FSorted := False;
  end;
end;

function TIntegerList.MaxValue: integer;
var
  Index: integer;
begin
  { TODO : Check if the list is sorted. if so, this can be more efficient. }
  { TODO : Maybe raise an error if Count = 0. }
  if Count = 0 then
  begin
    result := 0;
  end
  else
  begin
    result := Items[0];
    for Index := 1 to Count - 1 do
    begin
      if Items[Index] > result then
      begin
        result := Items[Index];
      end;
    end;
  end;
end;

function TIntegerList.MinValue: integer;
var
  Index: integer;
begin
  { TODO : Check if the list is sorted. if so, this can be more efficient. }
  { TODO : Maybe raise an error if Count = 0. }
  if Count = 0 then
  begin
    result := 0;
  end
  else
  begin
    result := Items[0];
    for Index := 1 to Count - 1 do
    begin
      if Items[Index] < result then
      begin
        result := Items[Index];
      end;
    end;
  end;
end;

function TIntegerList.Nearest(const TestValue: integer): integer;
var
  Index: integer;
  Delta, Test: integer;
  Top, Bottom, Middle: integer;
begin
  if Sorted then
  begin
    if FList.Count = 0 then
    begin
      result := -1;
    end
    else
    begin
      if (Items[0] > TestValue) then
      begin
        result := 0
      end
      else if (Items[Count - 1] < TestValue) then
      begin
        result := Count - 1;
      end
      else
      begin
        Top := Count - 1;
        Bottom := 0;
        while Top - Bottom > 1 do
        begin
          Middle := (Top + Bottom) div 2;
          if Items[Middle] < TestValue then
          begin
            Bottom := Middle;
          end
          else
          begin
            Top := Middle;
          end;
        end; // While Top - Bottom > 1 do
        if Items[Bottom] = TestValue then
        begin
          result := Bottom;
        end
        else if Items[Top] = TestValue then
        begin
          result := Top;
        end
        else
        begin
          if Abs(Items[Bottom] - TestValue) < Abs(Items[Top] - TestValue) then
          begin
            result := Bottom;
          end
          else
          begin
            result := Top;
          end;
        end;
      end;
    end;
  end
  else
  begin
    result := -1;
    if Count > 0 then
    begin
      Delta := Abs(Items[0] - TestValue);
      result := 0;
      for Index := 1 to Count - 1 do
      begin
        Test := Abs(Items[Index] - TestValue);
        if Test < Delta then
        begin
          Delta := Test;
          result := Index;
        end;
      end;
    end;

  end;
end;



end.

