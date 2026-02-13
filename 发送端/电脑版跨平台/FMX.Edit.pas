{*******************************************************}
{                                                       }
{              Delphi FireMonkey Platform               }
{                                                       }
{ Copyright(c) 2011-2025 Embarcadero Technologies, Inc. }
{              All rights reserved                      }
{                                                       }
{*******************************************************}

unit FMX.Edit;

interface

{$SCOPEDENUMS ON}

uses
  System.Classes, System.Types, System.UITypes, System.Rtti, FMX.Platform, FMX.Types, FMX.StdCtrls, FMX.Controls,
  FMX.Text, FMX.Graphics, FMX.Presentation.Messages, FMX.Controls.Presentation, FMX.Controls.Model, FMX.Clipboard,
  FMX.Text.UndoManager;

const
  MM_EDIT_SELSTART_CHANGED = MM_USER + 1;
  MM_EDIT_SELLENGTH_CHANGED = MM_USER + 2;
  MM_EDIT_READONLY_CHANGED = MM_USER + 3;
  MM_EDIT_MAXLENGTH_CHANGED = MM_USER + 4;
  MM_EDIT_ISPASSWORD_CHANGED = MM_USER + 5;
  MM_EDIT_IMEMODE_CHANGED = MM_USER + 6;
  MM_EDIT_KEYBOARDTYPE_CHANGED = MM_USER + 7;
  MM_EDIT_RETURNKEYTYPE_CHANGED = MM_USER + 8;
  MM_EDIT_KILLFOCUSBYRETURN_CHANGED = MM_USER + 9;
  MM_EDIT_CHECKSPELLING_CHANGED = MM_USER + 10;
  MM_EDIT_PROMPTTEXT_CHANGED = MM_USER + 11;
  MM_EDIT_CARETPOSITION_CHANGED = MM_USER + 15;
  MM_EDIT_CARETCHANGED = MM_USER + 16;
  MM_EDIT_TYPING_CHANGED = MM_USER + 17;
  MM_EDIT_TEXT_SETTINGS_CHANGED = MM_USER + 18;
  MM_EDIT_TEXT_CHANGED = MM_USER + 19;
  MM_EDIT_EDITBUTTONS_CHANGED = MM_USER + 21;
  MM_EDIT_TEXT_CHANGING = MM_USER + 22;
  MM_EDIT_CHARCASE_CHANGED = MM_USER + 23;
  MM_EDIT_FILTERCHAR_CHANGED = MM_USER + 24;
  MM_EDIT_GET_CARET_POSITION_BY_POINT = MM_USER + 25;
  MM_EDIT_CAN_SET_FOCUS = MM_USER + 26;
  MM_EDIT_AUTOSELECT_CHANGED = MM_USER + 27;
  MM_EDIT_HIDESELECTIONONEXIT_CHANGED = MM_USER + 28;
  MM_EDIT_USER = MM_USER + 29;

  PM_EDIT_REALIGN_BUTTONS_CONTAINER = PM_USER + 1;
  PM_EDIT_GET_TEXT_CONTENT_RECT = PM_USER + 2;
  PM_EDIT_UNDO_MANAGER_INSERT_TEXT = PM_USER + 3;
  PM_EDIT_UNDO_MANAGER_DELETE_TEXT = PM_USER + 4;
  PM_EDIT_UNDO_MANAGER_UNDO = PM_USER + 5;
  PM_EDIT_USER = PM_USER + 6;

type

{ TCustomEdit }

  TCustomEditModel = class(TDataModel, ITextLinesSource)
  public const
    DefaultSelectionColor = $802A8ADF;
    DefaultHorzAlign = TTextAlign.Leading;
    DefaultFontColor = TAlphaColorRec.Black;
    DefaultInputSupport = True;
    DefaultCharCase = TEditCharCase.ecNormal;
    DefaultAutoSelect = False;
    DefaultHideSelectionOnExit = True;
  public type
    /// <summary>Data for requesting caret position by HitTest point.</summary>
    TGetCaretPositionInfo = record
      HitPoint: TPointF;
      CaretPosition: Integer;
    end;
  private
    FChanged: Boolean;
    FText: string;
    FSelStart: Integer;
    FSelLength: Integer;
    FReadOnly: Boolean;
    FMaxLength: Integer;
    FPassword: Boolean;
    FKeyboardType : TVirtualkeyboardType;
    FReturnKeyType: TReturnKeyType;
    FImeMode: TImeMode;
    FHideSelectionOnExit: Boolean;
    FKillFocusByReturn: Boolean;
    FCheckSpelling: Boolean;
    FTextPrompt: string;
    FCaretPosition: Integer;
    FCaret: TCustomCaret;
    FTyping: Boolean;
    FFilterChar: string;
    FInputSupport: Boolean;
    FTextSettingsInfo: TTextSettingsInfo;
    FSelectionFill: TBrush;
    FOnChange: TNotifyEvent;
    FOnChangeTracking: TNotifyEvent;
    FOnTyping: TNotifyEvent;
    FOnValidating: TValidateTextEvent;
    FOnValidate: TValidateTextEvent;
    FValidating: Boolean;
    FCharCase: TEditCharCase;
    FAutoSelect: Boolean;
    procedure SetAutoSelect(const Value: Boolean);
    procedure SetSelStart(const Value: Integer);
    procedure SetSelLength(const Value: Integer);
    procedure SetMaxLength(const Value: Integer);
    procedure SetReadOnly(const Value: Boolean);
    procedure SetPassword(const Value: Boolean);
    procedure SetImeMode(const Value: TImeMode);
    procedure SetKeyboardType(const Value: TVirtualKeyboardType);
    procedure SetReturnKeyType(const Value: TReturnKeyType);
    procedure SetKillFocusByReturn(const Value: Boolean);
    procedure SetCheckSpelling(const Value: Boolean);
    procedure SetTextPrompt(const Value: string);
    procedure SetCaretPosition(const Value: Integer);
    procedure SetCaret(const Value: TCustomCaret);
    procedure SetTyping(const Value: Boolean);
    /// <remarks>
    ///   Invokes sequence: DoFiltering -> DoTruncating -> DoValidating
    /// </remarks>
    procedure SetText(const Value: string);
    procedure SetSelectionFill(const Value: TBrush);
    procedure SetFilterChar(const Value: string);
    procedure SetCharCase(const Value: TEditCharCase);
    function CanSetFocus: Boolean;
    procedure SetHideSelectionOnExit(const Value: Boolean);
    { ITextLinesSource }
    function GetLine(const ALineIndex: Integer): string;
    function GetLineBreak: string;
    function GetCount: Integer;
    function TextPosToPos(const APos: Integer): TCaretPosition;
    function PosToTextPos(const APosition: TCaretPosition): Integer;
    function GetText: string;
  protected
    ///<summary>Initial text filtering before calling <c>DoTruncating</c></summary>
    function DoFiltering(const Value: string): string; virtual;
    ///<summary>Maximum available text length filtering before calling <c>DoValidating</c></summary>
    function DoTruncating(const Value: string): string; virtual;
    ///<summary>Validate inputing text. Calling before OnChangeTracking</summary>
    function DoValidating(const Value: string): string; virtual;
    function DoValidate(const Value: string): string; virtual;
    procedure DoChangeTracking; virtual;
    procedure DoChange; virtual;
    procedure ResultTextSettingsChanged; virtual;
    function GetTextSettingsClass: TTextSettingsInfo.TCustomTextSettingsClass; virtual;
    /// <summary>
    ///   This property indicates that the control is in validate value mode. See DoValidate, Change
    /// </summary>
    property Validating: Boolean read FValidating;
  public
    constructor Create; override;
    destructor Destroy; override;
    function HasSelection: Boolean;
    function SelectedText: string;
    procedure Change;
    ///<summary>Set text in model without text validation and sending notification to presenter</summary>
    procedure SetTextWithoutValidation(const Value: string);

    { Editing }
    ///<summary>Insert text in memo after defined position</summary>
    procedure InsertAfter(const APosition: Integer; const AFragment: string; const Options: TInsertOptions);
    ///<summary>Delete fragment of the text from the memo after defined position</summary>
    procedure DeleteFrom(const APosition: Integer; const ALength: Integer; const Options: TDeleteOptions);
    /// <summary>Replace fragment of text from the memo in the specifeid range.</summary>
    procedure Replace(const APosition: Integer; const ALength: Integer; const AFragment: string);

    function GetPositionShift(const APosition: Integer; const ADelta: Integer): Integer;
    function GetNextWordBegin(const APosition: Integer): Integer;
    function GetPrevWordBegin(const APosition: Integer): Integer;
    { Caret position }
    procedure MoveCaretHorizontal(const ADelta: Integer);
    procedure MoveCaretLeft;
    procedure MoveCaretRight;
    /// <summary>Returns caret position by specified hittest point.</summary>
    /// <remarks>Works only for <c>TEdit.ControlType=Styled</c>.</remarks>
    function GetCaretPositionByPoint(const AHitPoint: TPointF): Integer;
  public
    ///<summary>Select all text when control getting focus</summary>
    property AutoSelect: Boolean read FAutoSelect write SetAutoSelect;
    property CaretPosition: Integer read FCaretPosition write SetCaretPosition;
    property Caret: TCustomCaret read FCaret write SetCaret;
    property CheckSpelling: Boolean read FCheckSpelling write SetCheckSpelling;
    property FilterChar: string read FFilterChar write SetFilterChar;
    ///<summary>Do not draw selected text region when component not in focus</summary>
    property HideSelectionOnExit: Boolean read FHideSelectionOnExit write SetHideSelectionOnExit default True;
    ///<summary>Text control is in read-only mode</summary>
    property ReadOnly: Boolean read FReadOnly write SetReadOnly;
    property ImeMode: TImeMode read FImeMode write SetImeMode;
    property InputSupport: Boolean read FInputSupport write FInputSupport;
    property KeyboardType : TVirtualkeyboardType read FKeyboardType write SetKeyboardType;
    property KillFocusByReturn: Boolean read FKillFocusByReturn write SetKillFocusByReturn;
    property MaxLength: Integer read FMaxLength write SetMaxLength;
    property Password: Boolean read FPassword write SetPassword;
    property ReturnKeyType: TReturnKeyType read FReturnKeyType write SetReturnKeyType;
    property SelectionFill: TBrush read FSelectionFill write SetSelectionFill;
    property SelStart: Integer read FSelStart write SetSelStart;
    property SelLength: Integer read FSelLength write SetSelLength;
    property Text: string read FText write SetText;
    property TextSettingsInfo: TTextSettingsInfo read FTextSettingsInfo;
    property TextPrompt: string read FTextPrompt write SetTextPrompt;
    property Typing: Boolean read FTyping write SetTyping;
    ///<summary>Defines character case for text in component</summary>
    property CharCase: TEditCharCase read FCharCase write SetCharCase;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnChangeTracking: TNotifyEvent read FOnChangeTracking write FOnChangeTracking;
    property OnTyping: TNotifyEvent read FOnTyping write FOnTyping;
    property OnValidating: TValidateTextEvent read FOnValidating write FOnValidating;
    property OnValidate: TValidateTextEvent read FOnValidate write FOnValidate;
  end;

  TCustomEdit = class;

  TContentEdit = class(TContent)
  private
    function GetEdit: TCustomEdit;
  protected
    procedure DoRemoveObject(const AObject: TFmxObject); override;
    procedure DoAddObject(const AObject: TFmxObject); override;
    procedure DoInsertObject(Index: Integer; const AObject: TFmxObject); override;
  public
    constructor Create(AOwner: TComponent); override;
    property Edit: TCustomEdit read GetEdit;
  end;

  TCustomEdit = class(TPresentedControl, ITextActions, IVirtualKeyboardControl, IItemsContainer, ITextSettings,
    IReadOnly, ICaret)
  private
    FButtonsContent: TContentEdit;
    FSavedReadOnly: Boolean;
    FSavedMaxLength: Integer;
    FSavedTextAlign: TTextAlign;
    function GetAutoSelect: Boolean;
    procedure SetAutoSelect(const Value: Boolean);
    function GetOriginCaretPosition: Integer;
    procedure SetSelText(const Value: string);
    function GetSelText: string;
    procedure SetSelLength(const Value: Integer);
    function GetSelLength: Integer;
    procedure SetSelStart(const Value: Integer);
    function GetSelStart: Integer;
    procedure SetCaretPosition(const Value: Integer);
    function GetCaretPosition: Integer;
    procedure SetCaret(const Value: TCustomCaret);
    function GetCaret: TCustomCaret;
    procedure SetPromptText(const Prompt: string);
    function GetPromptText: string;
    procedure SetOnChange(const Value: TNotifyEvent);
    function GetOnChange: TNotifyEvent;
    procedure SetOnChangeTracking(const Value: TNotifyEvent);
    function GetOnChangeTracking: TNotifyEvent;
    procedure SetMaxLength(const Value: Integer);
    function GetMaxLength: Integer;
    procedure SetPassword(const Value: Boolean);
    function GetPassword: Boolean;
    procedure SetOnTyping(const Value: TNotifyEvent);
    function GetOnTyping: TNotifyEvent;
    procedure SetKillFocusByReturn(const Value: Boolean);
    function GetKillFocusByReturn: Boolean;
    procedure SetCheckSpelling(const Value: Boolean);
    function GetCheckSpelling: Boolean;
    function GetSelectionFill: TBrush;
    function GetCharCase: TEditCharCase;
    procedure SetCharCase(const Value: TEditCharCase);
    { ITextSettings }
    function GetDefaultTextSettings: TTextSettings;
    function GetTextSettings: TTextSettings;
    function GetResultingTextSettings: TTextSettings;
    function GetStyledSettings: TStyledSettings;
    procedure SetTextAlign(const Value: TTextAlign);
    function GetTextAlign: TTextAlign;
    procedure SetVertTextAlign(const Value: TTextAlign);
    function GetVertTextAlign: TTextAlign;
    procedure SetFont(const Value: TFont);
    function GetFont: TFont;
    procedure SetFontColor(const Value: TAlphaColor);
    function GetFontColor: TAlphaColor;
    function GetTyping: Boolean;
    procedure SetTyping(const Value: Boolean);
    function GetFilterChar: string;
    procedure SetFilterChar(const Value: string);
    function GetInputSupport: Boolean;
    function GetModel: TCustomEditModel; overload;
    function GetTextContentRect: TRectF;
    function GetOnValidate: TValidateTextEvent;
    function GetOnValidating: TValidateTextEvent;
    procedure SetOnValidate(const Value: TValidateTextEvent);
    procedure SetOnValidating(const Value: TValidateTextEvent);
    procedure ReadReadOnly(Reader: TReader);
    function GetHideSelectionOnExit: Boolean;
    procedure SetHideSelectionOnExit(const Value: Boolean);
    { IReadOnly }
    procedure SetReadOnly(const Value: Boolean);
    function GetReadOnly: Boolean;
    { ICaret }
    function ICaret.GetObject = GetCaret;
    procedure ShowCaret;
    procedure HideCaret;
  protected
    FClipboardSvc: IFMXExtendedClipboardService;
    function GetData: TValue; override;
    procedure SetData(const Value: TValue); override;
    procedure Loaded; override;
    function GetText: string; virtual;
    procedure SetText(const Value: string); virtual;
    procedure DoAddObject(const AObject: TFmxObject); override;
    procedure DoInsertObject(Index: Integer; const AObject: TFmxObject); override;
    procedure DoRemoveObject(const AObject: TFmxObject); override;
    function GetImeMode: TImeMode; virtual;
    procedure SetImeMode(const Value: TImeMode); virtual;
    procedure SetInputSupport(const Value: Boolean); virtual;
    procedure DefineProperties(Filer: TFiler); override;
    function GetDefaultSize: TSizeF; override;
    procedure Resize; override;
    procedure RealignButtonsContainer; virtual;
    function GetCanFocus: Boolean; override;
    { Live Binding }
    function CanObserve(const ID: Integer): Boolean; override;
    procedure ObserverAdded(const ID: Integer; const Observer: IObserver); override;
    procedure ObserverToggle(const AObserver: IObserver; const Value: Boolean);
    { ITextSettings }
    procedure SetTextSettings(const Value: TTextSettings); virtual;
    procedure SetStyledSettings(const Value: TStyledSettings); virtual;
    function StyledSettingsStored: Boolean; virtual;
    { IVirtualKeyboardControl }
    procedure SetKeyboardType(Value: TVirtualKeyboardType);
    function GetKeyboardType: TVirtualKeyboardType;
    procedure SetReturnKeyType(Value: TReturnKeyType);
    function GetReturnKeyType: TReturnKeyType;
    function IVirtualKeyboardControl.IsPassword = GetPassword;
    property InputSupport: Boolean read GetInputSupport write SetInputSupport;
    { IItemsContainer }
    function GetItemsCount: Integer;
    function GetItem(const AIndex: Integer): TFmxObject;
    procedure ButtonsChanged; virtual;
  protected
    function DefineModelClass: TDataModelClass; override;
    function DefinePresentationName: string; override;
  public
    property ControlType;
    property Model: TCustomEditModel read GetModel;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure SelectAll(const AKeepCaretPosition: Boolean); overload;
    { ITextActions }
    procedure DeleteSelection;
    procedure CopyToClipboard;
    procedure CutToClipboard;
    procedure PasteFromClipboard;
    procedure SelectAll; overload;
    procedure SelectWord;
    procedure ResetSelection;
    procedure GoToTextEnd;
    procedure GoToTextBegin;
    procedure Replace(const AStartPos: Integer; const ALength: Integer; const AStr: string);
    function HasSelection: Boolean;
    procedure Undo;
  public
    ///<summary>Determines whether all the text in the edit is automatically selected when the control gets
    ///focus</summary>
    property AutoSelect: Boolean read GetAutoSelect write SetAutoSelect;
    property ButtonsContent: TContentEdit read FButtonsContent;
    property Caret: TCustomCaret read GetCaret write SetCaret;
    property CaretPosition: Integer read GetCaretPosition write SetCaretPosition;
    property TextContentRect: TRectF read GetTextContentRect;
    property CheckSpelling: Boolean read GetCheckSpelling write SetCheckSpelling default False;
    property DefaultTextSettings: TTextSettings read GetDefaultTextSettings;
    property Font: TFont read GetFont write SetFont;
    property FontColor: TAlphaColor read GetFontColor write SetFontColor default TAlphaColorRec.Black;
    property FilterChar: string read GetFilterChar write SetFilterChar;
    property ImeMode: TImeMode read GetImeMode write SetImeMode default TImeMode.imDontCare;
    property KeyboardType: TVirtualKeyboardType read GetKeyboardType write SetKeyboardType default TVirtualKeyboardType.Default;
    property KillFocusByReturn: Boolean read GetKillFocusByReturn write SetKillFocusByReturn default False;
    property MaxLength: Integer read GetMaxLength write SetMaxLength default 0;
    ///<summary>Determines whether to cancel the visual indication of the selected text when the focus moves to another
    ///control.</summary>
    property HideSelectionOnExit: Boolean read GetHideSelectionOnExit write SetHideSelectionOnExit;
    property Password: Boolean read GetPassword write SetPassword default False;
    property ReadOnly: Boolean read GetReadOnly write SetReadOnly default False;
    property ReturnKeyType: TReturnKeyType read GetReturnKeyType write SetReturnKeyType default TReturnKeyType.Default;
    property ResultingTextSettings: TTextSettings read GetResultingTextSettings;
    property SelectionFill: TBrush read GetSelectionFill;
    property SelStart: Integer read GetSelStart write SetSelStart;
    property SelLength: Integer read GetSelLength write SetSelLength;
    property SelText: string read GetSelText write SetSelText;
    property StyledSettings: TStyledSettings read GetStyledSettings write SetStyledSettings stored StyledSettingsStored nodefault;
    property Text: string read GetText write SetText;
    property TextAlign: TTextAlign read GetTextAlign write SetTextAlign default TTextAlign.Leading;
    property TextSettings: TTextSettings read GetTextSettings write SetTextSettings;
    property TextPrompt: string read GetPromptText write SetPromptText;
    property Typing: Boolean read GetTyping write SetTyping default False;
    property VertTextAlign: TTextAlign read GetVertTextAlign write SetVertTextAlign default TTextAlign.Center;
    ///<summary>Defines whether to implement the 'UPPER' or 'lower' case conversion to the memo's text</summary>
    property CharCase: TEditCharCase read GetCharCase write SetCharCase;
    property OnChange: TNotifyEvent read GetOnChange write SetOnChange;
    property OnChangeTracking: TNotifyEvent read GetOnChangeTracking write SetOnChangeTracking;
    property OnTyping: TNotifyEvent read GetOnTyping write SetOnTyping;
    property OnValidating: TValidateTextEvent read GetOnValidating write SetOnValidating;
    property OnValidate: TValidateTextEvent read GetOnValidate write SetOnValidate;
  published
    property Align;
    property Anchors;
    property StyleLookup;
    property TabOrder;
    property TabStop;
  end;

{ TEditButton }

  IEditControl = interface
    ['{4C7EE0A7-06EC-4515-B843-B608FB984468}']
    function BoundsRect: TRectF;
    function GetControl: TControl;
  end;

  TEditButton = class(TCustomButton, IEditControl)
  protected
    function GetDefaultStyleLookupName: string; override;
    procedure SetName(const NewName: TComponentName); override;
    function GetDefaultSize: TSizeF; override;
    { IEditControl }
    function IEditControl.BoundsRect = GetBoundsRect;
    function GetControl: TControl;
  public
    constructor Create(AOwner: TComponent); override;
    function GetEdit: TCustomEdit;
  published
    property Action;
    property Anchors;
    property AutoTranslate default True;
    property CanFocus default True;
    property CanParentFocus;
    property ClipChildren default False;
    property ClipParent default False;
    property Cursor default crDefault;
    property DisableFocusEffect;
    property DragMode default TDragMode.dmManual;
    property EnableDragHighlight default True;
    property Enabled default True;
    property TextSettings;
    property Font;
    property Height;
    property HelpContext;
    property HelpKeyword;
    property HelpType;
    property Hint;
    property HitTest default True;
    property IsPressed default False;
    property Locked default False;
    property Padding;
    property ModalResult default mrNone;
    property Opacity;
    property Margins;
    property PopupMenu;
    property Position;
    property RepeatClick default False;
    property RotationAngle;
    property RotationCenter;
    property Scale;
    property Size;
    property StaysPressed default False;
    property StyleLookup;
    property TabOrder;
    property Text;
    property TextAlign default TTextAlign.Center;
    property TouchTargetExpansion;
    property Visible default True;
    property Width;
    property WordWrap default False;
    property ParentShowHint;
    property ShowHint;
    {events}
    property OnApplyStyleLookup;
    property OnFreeStyle;
    property OnDragEnter;
    property OnDragLeave;
    property OnDragOver;
    property OnDragDrop;
    property OnDragEnd;
    property OnKeyDown;
    property OnKeyUp;
    property OnCanFocus;
    property OnClick;
    property OnDblClick;
    property OnEnter;
    property OnExit;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnMouseWheel;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnPainting;
    property OnPaint;
    property OnResize;
    property OnResized;
  end;

{ TClearEditButton }

  TClearEditButton = class(TEditButton)
  protected
    procedure Click; override;
    function GetDefaultStyleLookupName: string; override;
  end;

{ TPasswordEditButton }

  TPasswordEditButton = class(TEditButton)
  protected
    function GetDefaultStyleLookupName: string; override;
  public
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X: Single; Y: Single); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X: Single; Y: Single); override;
  end;

{ TSearchEditButton }

  TSearchEditButton = class(TEditButton)
  protected
    function GetDefaultStyleLookupName: string; override;
  end;

{ TEllipsesEditButton }

  TEllipsesEditButton = class(TEditButton)
  protected
    function GetDefaultStyleLookupName: string; override;
  end;

{ TDropDownEditButton }

  TDropDownEditButton = class(TEditButton)
  protected
    function GetDefaultStyleLookupName: string; override;
  end;

{ TSpinEditButton }

  TSpinEditButton = class(TStyledControl, IEditControl)
  private
    FRepeatClick: Boolean;
    { Style }
    FUpButton: TCustomButton;
    FDownButton: TCustomButton;
    { Events }
    FOnUpClick: TNotifyEvent;
    FOnDownClick: TNotifyEvent;
    procedure SetRepeatClick(const Value: Boolean);
  protected
    { Style }
    procedure ApplyStyle; override;
    procedure FreeStyle; override;
    function GetDefaultStyleLookupName: string; override;
    function GetDefaultSize: TSizeF; override;
    { Events }
    procedure DoUpButtonClick(Sender: TObject);
    procedure DoDownButtonClick(Sender: TObject);
    { IEditControl }
    function IEditControl.BoundsRect = GetBoundsRect;
    function GetControl: TControl;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Anchors;
    property AutoTranslate default True;
    property CanFocus default True;
    property CanParentFocus;
    property ClipChildren default False;
    property ClipParent default False;
    property Cursor default crDefault;
    property DisableFocusEffect;
    property DragMode default TDragMode.dmManual;
    property EnableDragHighlight default True;
    property Enabled default True;
    property Height;
    property HelpContext;
    property HelpKeyword;
    property HelpType;
    property Hint;
    property HitTest default True;
    property Locked default False;
    property Padding;
    property Opacity;
    property Margins;
    property PopupMenu;
    property Position;
    property RepeatClick: Boolean read FRepeatClick write SetRepeatClick default False;
    property RotationAngle;
    property RotationCenter;
    property Scale;
    property Size;
    property StyleLookup;
    property TabOrder;
    property TouchTargetExpansion;
    property Visible default True;
    property Width;
    property ParentShowHint;
    property ShowHint;
    {events}
    property OnApplyStyleLookup;
    property OnFreeStyle;
    property OnDragEnter;
    property OnDragLeave;
    property OnDragOver;
    property OnDragDrop;
    property OnDragEnd;
    property OnKeyDown;
    property OnKeyUp;
    property OnDownClick: TNotifyEvent read FOnDownClick write FOnDownClick;
    property OnUpClick: TNotifyEvent read FOnUpClick write FOnUpClick;
    property OnCanFocus;
    property OnClick;
    property OnDblClick;
    property OnEnter;
    property OnExit;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnMouseWheel;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnPainting;
    property OnPaint;
    property OnResize;
    property OnResized;
  end;

{ TEdit }

  TEdit = class(TCustomEdit)
  public
    property Action;
  published
    property ControlType;
    property OnPresentationNameChoosing;
    { inherited }
    property AutoSelect default TCustomEditModel.DefaultAutoSelect;
    property Cursor default crIBeam;
    property CanFocus default True;
    property CanParentFocus;
    property DisableFocusEffect;
    property KeyboardType;
    property ReturnKeyType;
    property Password;
    property ReadOnly;
    ///<summary>Maxmimum length of text that can be input in the edit field.</summary>
    ///<remarks>On Android due to platform limitations text is truncated only after pressing ENTER key or after losing
    ///focus.</remarks>
    property MaxLength;
    property HideSelectionOnExit default TCustomEditModel.DefaultHideSelectionOnExit;
    ///<summary>Defines characters which can be input in the edit field. All characters not in FilterChar will be
    ///ignored. Empty FilterChar value means no filtering.</summary>
    ///<remarks>On Android due to platform limitations text is filtered only after pressing ENTER key or after control
    ///losing focus.</remarks>
    property FilterChar;
    property Text;
    property TextSettings;
    property ImeMode;
    property Position;
    property Width;
    property Height;
    property ClipChildren default False;
    property ClipParent default False;
    property DragMode default TDragMode.dmManual;
    property EnableDragHighlight default True;
    property Enabled default True;
    property Locked default False;
    property Hint;
    property HitTest default True;
    property HelpContext;
    property HelpKeyword;
    property HelpType;
    property Padding;
    property Opacity;
    property Margins;
    property PopupMenu;
    property RotationAngle;
    property RotationCenter;
    property Scale;
    property Size;
    property TextPrompt;
    property StyleLookup;
    property StyledSettings;
    property TouchTargetExpansion;
    property Visible default True;
    property Caret;
    property KillFocusByReturn;
    property CheckSpelling;
    property ParentShowHint;
    property ShowHint;
    property CharCase default TCustomEditModel.DefaultCharCase;
    { events }
    property OnChange;
    property OnChangeTracking;
    property OnTyping;
    property OnApplyStyleLookup;
    property OnFreeStyle;
    property OnValidating;
    property OnValidate;
    property OnDragEnter;
    property OnDragLeave;
    property OnDragOver;
    property OnDragDrop;
    property OnDragEnd;
    property OnKeyDown;
    property OnKeyUp;
    property OnCanFocus;
    property OnClick;
    property OnDblClick;
    property OnEnter;
    property OnExit;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnMouseWheel;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnPainting;
    property OnPaint;
    property OnResize;
    property OnResized;
  end;

{ TClearingEdit }

  TClearingEdit = class(TEdit)
  protected
    function DefinePresentationName: string; override;
    function GetDefaultStyleLookupName: string; override;
  public
    constructor Create(AOwner: TComponent); override;
  end deprecated 'Use TEdit with TClearEditButton';

implementation

uses
  System.SysUtils, System.Character, System.Math, FMX.Consts, FMX.Edit.Style.New, FMX.BehaviorManager, FMX.Utils
  {$IFDEF MSWINDOWS}, FMX.Edit.Win{$ENDIF}{$IFDEF IOS}, FMX.Edit.iOS{$ENDIF}{$IFDEF ANDROID}, FMX.Edit.Android{$ENDIF};

type
  TEditSettingsInfo = class(TTextSettingsInfo)
  private
    [Weak] FEditModel: TCustomEditModel;
  protected
    procedure DoCalculatedTextSettings; override;
  public
    constructor Create(AOwner: TPersistent; ATextSettingsClass: TTextSettingsInfo.TCustomTextSettingsClass); override;
    property EditModel: TCustomEditModel read FEditModel;
  end;

{ TEditSettingsInfo }

constructor TEditSettingsInfo.Create(AOwner: TPersistent; ATextSettingsClass: TTextSettingsInfo.TCustomTextSettingsClass);
begin
  inherited;
  if AOwner is TCustomEditModel then
    FEditModel := TCustomEditModel(AOwner)
  else
    raise EArgumentException.CreateFMT(SEUseHeirs, [TCustomEditModel.ClassName]);
end;

procedure TEditSettingsInfo.DoCalculatedTextSettings;
begin
  FEditModel.ResultTextSettingsChanged;
  inherited;
end;

{ TCustomEdit }

constructor TCustomEdit.Create(AOwner: TComponent);
begin
  inherited;
  EnableExecuteAction := False;
  if not TPlatformServices.Current.SupportsPlatformService(IFMXExtendedClipboardService, IInterface(FClipboardSvc)) then
    FClipboardSvc := nil;
  CanFocus := True;
  Cursor := crIBeam;
  SetAcceptsControls(False);
  CanUseDefaultPresentation := False;
  FButtonsContent := TContentEdit.Create(Self);
  FButtonsContent.Parent := Self;
  FButtonsContent.Locked := True;
  FButtonsContent.Stored := False;
  FButtonsContent.HitTest := False;
  Touch.InteractiveGestures := Touch.InteractiveGestures + [TInteractiveGesture.DoubleTap, TInteractiveGesture.LongTap];
end;

destructor TCustomEdit.Destroy;
begin
  FButtonsContent := nil;
  FClipboardSvc := nil;
  inherited;
end;

function TCustomEdit.GetOnChange: TNotifyEvent;
begin
  Result := Model.OnChange;
end;

function TCustomEdit.GetOnChangeTracking: TNotifyEvent;
begin
  Result := Model.OnChangeTracking;
end;

function TCustomEdit.GetOnTyping: TNotifyEvent;
begin
  Result := Model.OnTyping;
end;

function TCustomEdit.GetOnValidate: TValidateTextEvent;
begin
  Result := Model.OnValidate;
end;

function TCustomEdit.GetOnValidating: TValidateTextEvent;
begin
  Result := Model.OnValidating;
end;

function TCustomEdit.GetOriginCaretPosition: Integer;
begin
  Result := Model.CaretPosition;
end;

procedure TCustomEdit.SetAutoSelect(const Value: Boolean);
begin
  Model.AutoSelect := Value;
end;

procedure TCustomEdit.SetCaret(const Value: TCustomCaret);
begin
  Model.Caret.Assign(Value);
end;

function TCustomEdit.DefineModelClass: TDataModelClass;
begin
  Result := TCustomEditModel;
end;

function TCustomEdit.DefinePresentationName: string;
begin
  Result := 'Edit-' + GetPresentationSuffix;
end;

procedure TCustomEdit.DefineProperties(Filer: TFiler);
var
  LTextPropLoader: TTextSettingsInfo.TTextPropLoader;
begin
  inherited;
  Filer.DefineProperty('IsReadOnly', ReadReadOnly, nil, False); // do not localize
  // Only for backward compatibility with old versions
  LTextPropLoader := TTextSettingsInfo.TTextPropLoader.Create(Self, Filer);
  try
    LTextPropLoader.ReadProperties;
  finally
    LTextPropLoader.Free;
  end;
end;

function TCustomEdit.GetData: TValue;
begin
  Result := Text;
end;

procedure TCustomEdit.SetData(const Value: TValue);
begin
  if Value.IsEmpty then
    Text := string.Empty
  else
    if Value.IsType<TNotifyEvent> then
      OnChange := Value.AsType<TNotifyEvent>()
    else
      Text := Value.ToString;
end;

function TCustomEdit.GetKeyboardType: TVirtualKeyboardType;
begin
  Result := Model.KeyboardType;
end;

function TCustomEdit.GetKillFocusByReturn: Boolean;
begin
  Result := Model.KillFocusByReturn;
end;

function TCustomEdit.GetMaxLength: Integer;
begin
  Result := Model.MaxLength;
end;

function TCustomEdit.GetModel: TCustomEditModel;
begin
  Result := GetModel<TCustomEditModel>;
end;

function TCustomEdit.GetResultingTextSettings: TTextSettings;
begin
  Result := Model.TextSettingsInfo.ResultingTextSettings;
end;

function TCustomEdit.GetDefaultSize: TSizeF;
var
  MetricsService: IFMXDefaultMetricsService;
begin
  if (TBehaviorServices.Current.SupportsBehaviorService(IFMXDefaultMetricsService, MetricsService, Self)
    or SupportsPlatformService(IFMXDefaultMetricsService, MetricsService))
    and MetricsService.SupportsDefaultSize(TComponentKind.Edit) then
    Result := TSizeF.Create(MetricsService.GetDefaultSize(TComponentKind.Edit))
  else
    Result := TSizeF.Create(100, 22);
end;

function TCustomEdit.GetDefaultTextSettings: TTextSettings;
begin
  Result := Model.TextSettingsInfo.DefaultTextSettings;
end;

function TCustomEdit.GetTextSettings: TTextSettings;
begin
  Result := Model.TextSettingsInfo.TextSettings;
end;

type
  TEditTextSettings = class (TTextSettingsInfo.TCustomTextSettings)
  public
    constructor Create(const AOwner: TPersistent); override;
  published
    property Font;
    property FontColor;
    property HorzAlign default TTextAlign.Leading;
    property VertAlign default TTextAlign.Center;
  end;

{ TEditTextSettings }

constructor TEditTextSettings.Create(const AOwner: TPersistent);
begin
  inherited;
  WordWrap := False;
  HorzAlign := TTextAlign.Leading;
  VertAlign := TTextAlign.Center;
end;

function TCustomEdit.GetTyping: Boolean;
begin
  Result := Model.Typing;
end;

function TCustomEdit.GetStyledSettings: TStyledSettings;
begin
  Result := Model.TextSettingsInfo.StyledSettings;
end;

procedure TCustomEdit.SetTextSettings(const Value: TTextSettings);
begin
  Model.TextSettingsInfo.TextSettings.Assign(Value);
end;

procedure TCustomEdit.SetTyping(const Value: Boolean);
begin
  Model.Typing := Value;
end;

procedure TCustomEdit.SetStyledSettings(const Value: TStyledSettings);
begin
  Model.TextSettingsInfo.StyledSettings := Value;
end;

function TCustomEdit.GetFilterChar: string;
begin
  Result := Model.FilterChar;
end;

function TCustomEdit.GetFont: TFont;
begin
  Result := Model.TextSettingsInfo.TextSettings.Font;
end;

procedure TCustomEdit.SetFilterChar(const Value: string);
begin
  Model.FilterChar := Value;
end;

procedure TCustomEdit.SetFont(const Value: TFont);
begin
  Model.TextSettingsInfo.TextSettings.Font := Value;
end;

function TCustomEdit.GetFontColor: TAlphaColor;
begin
  Result := Model.TextSettingsInfo.TextSettings.FontColor;
end;

function TCustomEdit.GetHideSelectionOnExit: Boolean;
begin
  Result := Model.HideSelectionOnExit;
end;

procedure TCustomEdit.SetFontColor(const Value: TAlphaColor);
begin
  Model.TextSettingsInfo.TextSettings.FontColor := Value;
end;

procedure TCustomEdit.SetHideSelectionOnExit(const Value: Boolean);
begin
  Model.HideSelectionOnExit := Value;
end;

function TCustomEdit.GetTextAlign: TTextAlign;
begin
  Result := Model.TextSettingsInfo.TextSettings.HorzAlign;
end;

function TCustomEdit.GetTextContentRect: TRectF;
begin
  if HasPresentationProxy then
    PresentationProxy.SendMessageWithResult<TRectF>(PM_EDIT_GET_TEXT_CONTENT_RECT, Result)
  else
    Result := LocalRect;
end;

procedure TCustomEdit.SetTextAlign(const Value: TTextAlign);
begin
  Model.TextSettingsInfo.TextSettings.HorzAlign := Value;
  FSavedTextAlign := Value;
end;

function TCustomEdit.GetVertTextAlign: TTextAlign;
begin
  Result := Model.TextSettingsInfo.TextSettings.VertAlign;
end;

procedure TCustomEdit.SetVertTextAlign(const Value: TTextAlign);
begin
  Model.TextSettingsInfo.TextSettings.VertAlign := Value;
end;

procedure TCustomEdit.ShowCaret;
begin
  Caret.Show;
end;

function TCustomEdit.StyledSettingsStored: Boolean;
begin
  Result := StyledSettings <> DefaultStyledSettings;
end;

procedure TCustomEdit.Undo;
begin
  Model.SendMessage(PM_EDIT_UNDO_MANAGER_UNDO);
end;

procedure TCustomEdit.DoAddObject(const AObject: TFmxObject);
var
  EditControl: IEditControl;
begin
  if AObject.GetInterface(IEditControl, EditControl) then
  begin
    if not FButtonsContent.ContainsObject(AObject) then
    begin
      FButtonsContent.AddObject(AObject);
      if AObject is TControl then
        TControl(AObject).Cursor := crArrow;
    end;
  end
  else
    inherited DoAddObject(AObject);
end;

function TCustomEdit.GetPassword: Boolean;
begin
  Result := Model.Password;
end;

function TCustomEdit.GetCheckSpelling: Boolean;
begin
  Result := Model.CheckSpelling;
end;

function TCustomEdit.GetSelectionFill: TBrush;
begin
  Result := Model.SelectionFill;
end;

function TCustomEdit.GetCharCase: TEditCharCase;
begin
  Result := Model.CharCase;
end;

procedure TCustomEdit.SetCharCase(const Value: TEditCharCase);
begin
  Model.CharCase := Value;
end;

function TCustomEdit.GetReturnKeyType: TReturnKeyType;
begin
  Result := Model.ReturnKeyType;
end;

function TCustomEdit.GetSelStart: Integer;
begin
  if Model.SelLength > 0 then
    Result := Model.SelStart
  else if Model.SelLength < 0 then
    Result := Model.SelStart + Model.SelLength
  else
    Result := GetOriginCaretPosition;
end;

function TCustomEdit.GetSelLength: Integer;
begin
  Result := Abs(Model.SelLength);
end;

function TCustomEdit.GetSelText: string;
begin
  Result := Model.SelectedText;
end;

procedure TCustomEdit.SetSelLength(const Value: Integer);
begin
  Model.SelLength := Value;
end;

procedure TCustomEdit.SetSelStart(const Value: Integer);
begin
  Model.SelLength := 0;
  Model.SelStart := Value;
  Model.CaretPosition := Value;
end;

procedure TCustomEdit.SetSelText(const Value: string);

  procedure Normalize(var ASelStart: Integer; var ASelLength: Integer);
  begin
    if ASelLength < 0 then
    begin
      ASelStart := ASelStart + ASelLength;
      ASelLength := Abs(ASelLength);
    end;
  end;

var
  LSelStart: Integer;
  LSelLength: Integer;
begin
  if InRange(SelStart, 0, Text.Length - 1) then
  begin
    LSelStart := SelStart;
    LSelLength := SelLength;
    Normalize(LSelStart, LSelLength);
    Model.Replace(LSelStart, LSelLength, Value);

    SelStart := LSelStart;
    SelLength := Value.Length;
  end;
end;

procedure TCustomEdit.SetCaretPosition(const Value: Integer);
begin
  Model.CaretPosition := Value;
end;

procedure TCustomEdit.SetCheckSpelling(const Value: Boolean);
begin
  Model.CheckSpelling := Value;
end;

function TCustomEdit.GetAutoSelect: Boolean;
begin
  Result := Model.AutoSelect;
end;

function TCustomEdit.GetCanFocus: Boolean;
begin
  Result := (inherited GetCanFocus) and Model.CanSetFocus;
end;

function TCustomEdit.GetCaret: TCustomCaret;
begin
  Result := Model.Caret;
end;

function TCustomEdit.GetCaretPosition: Integer;
begin
  Result := Model.CaretPosition;
end;

procedure TCustomEdit.SetMaxLength(const Value: Integer);
begin
  Model.MaxLength := Value;
  FSavedMaxLength := Value;
end;

procedure TCustomEdit.SetOnChange(const Value: TNotifyEvent);
begin
  Model.OnChange := Value;
end;

procedure TCustomEdit.SetOnChangeTracking(const Value: TNotifyEvent);
begin
  Model.OnChangeTracking := Value;
end;

procedure TCustomEdit.SetOnTyping(const Value: TNotifyEvent);
begin
  Model.OnTyping := Value;
end;

procedure TCustomEdit.SetOnValidate(const Value: TValidateTextEvent);
begin
  Model.OnValidate := Value;
end;

procedure TCustomEdit.SetOnValidating(const Value: TValidateTextEvent);
begin
  Model.OnValidating := Value;
end;

procedure TCustomEdit.CopyToClipboard;
begin
  if (FClipboardSvc = nil) or Password then
    Exit;

  if InputSupport and not SelText.IsEmpty then
    FClipboardSvc.SetClipboard(SelText);

  if not InputSupport and not Text.IsEmpty then
    FClipboardSvc.SetClipboard(Text);
end;

procedure TCustomEdit.PasteFromClipboard;

  function HasNoAvailableSpace(const ACurrentTextLength: Integer): Boolean;
  begin
    Result := (MaxLength <> 0) and (MaxLength - ACurrentTextLength <= 0);
  end;

var
  OldText, InsertableString: string;
  LPos: Integer;
  InsertOptions: TInsertOptions;
begin
  if ReadOnly or not InputSupport or (FClipboardSvc = nil) or not FClipboardSvc.HasText then
    Exit;

  if Observers.IsObserving(TObserverMapping.EditLinkID) then
    if not TLinkObservers.EditLinkEdit(Observers) then
    begin
      TLinkObservers.EditLinkReset(Observers);
      Exit;
    end
    else
      TLinkObservers.EditLinkModified(Observers);
  if Observers.IsObserving(TObserverMapping.ControlValueID) then
    TLinkObservers.ControlValueModified(Observers);

  OldText := Model.Text;
  OldText := OldText.Remove(SelStart, SelLength);

  InsertableString := FClipboardSvc.GetText;
  LPos := InsertableString.IndexOf(sLineBreak);
  if LPos >= 0 then
    InsertableString := InsertableString.Substring(0, LPos);

  case Model.CharCase of
    TEditCharCase.ecUpperCase:
      InsertableString := InsertableString.ToUpper;
    TEditCharCase.ecLowerCase:
      InsertableString := InsertableString.ToLower;
  end;

  // Determination an insertable string length (checking MaxLength)
  if HasNoAvailableSpace(OldText.Length) then
    Exit;

  if MaxLength <> 0 then
    InsertableString := InsertableString.Substring(0, MaxLength - OldText.Length);

  if SelLength > 0 then
    InsertOptions := [TInsertOption.UndoPairedWithPrev]
  else
    InsertOptions := [];

  var LSelStart := SelStart;
  Model.DeleteFrom(LSelStart, SelLength, [TDeleteOption.CanUndo]);
  Model.InsertAfter(LSelStart, InsertableString, [TInsertOption.CanUndo, TInsertOption.MoveCaret] + InsertOptions);
end;

procedure TCustomEdit.ReadReadOnly(Reader: TReader);
begin
  ReadOnly := Reader.ReadBoolean;
end;

procedure TCustomEdit.RealignButtonsContainer;
var
  TotalWidth: Single;
  EditControl: IEditControl;
begin
  TotalWidth := 0;
  for var I := 0 to FButtonsContent.ChildrenCount - 1 do
    if Supports(FButtonsContent.Children[I], IEditControl, EditControl) then
      TotalWidth := TotalWidth + EditControl.BoundsRect.Width;

  FButtonsContent.BoundsRect := TRectF.Create(TPointF.Create(Width - TotalWidth, 0), TotalWidth, Height);
end;

procedure TCustomEdit.Replace(const AStartPos, ALength: Integer; const AStr: string);
begin
  Model.Replace(AStartPos, ALength, AStr);
end;

procedure TCustomEdit.ResetSelection;
var
  LCaretPosition: Integer;
begin
  LCaretPosition := GetSelStart + GetSelLength;
  SelLength := 0;
  CaretPosition := LCaretPosition;
end;

procedure TCustomEdit.Resize;
begin
  inherited;
  if not HasPresentationProxy then
    RealignButtonsContainer;
end;

procedure TCustomEdit.DeleteSelection;
begin
  if ReadOnly or not InputSupport or (SelLength = 0) then
    Exit;

  Model.DeleteFrom(SelStart, SelLength, [TDeleteOption.CanUndo, TDeleteOption.Selected, TDeleteOption.MoveCaret])
end;

procedure TCustomEdit.CutToClipboard;
begin
  if Observers.IsObserving(TObserverMapping.EditLinkID) then
    if not TLinkObservers.EditLinkEdit(Observers) then
    begin
      TLinkObservers.EditLinkReset(Observers);
      Exit;
    end
    else
      TLinkObservers.EditLinkModified(Observers);
  if Observers.IsObserving(TObserverMapping.ControlValueID) then
    TLinkObservers.ControlValueModified(Observers);

  CopyToClipboard;
  DeleteSelection;
end;

procedure TCustomEdit.SelectAll;
begin
  SelectAll(False);
end;

procedure TCustomEdit.SelectAll(const AKeepCaretPosition: Boolean);
var
  CaretPos: Integer;
begin
  if not InputSupport then
    Exit;

  if AKeepCaretPosition then
  begin
    if Password then
      CaretPos := Text.Length
    else
      CaretPos := CaretPosition;
  end
  else
    CaretPos := 0;
  try
    SelStart := 0;
    SelLength := Text.Length;
  finally
    if AKeepCaretPosition then
      CaretPosition := CaretPos;
  end;
end;

procedure TCustomEdit.SelectWord;
var
  WordBeginIndex, WordEndIndex: Integer;
  CaretPos: Integer;
begin
  if Text.Length = 0 then
    Exit;

  if Password then
    SelectAll
  else
  begin
    CaretPos := GetOriginCaretPosition;
    if FindWordBound(Text, CaretPos, WordBeginIndex, WordEndIndex) and InRange(CaretPos, WordBeginIndex, WordEndIndex + 1) then
    begin
      Model.SelStart := WordBeginIndex;
      Model.SelLength := Max(WordEndIndex - Model.SelStart + 1, 0);
      Model.CaretPosition := WordEndIndex + 1;
    end
    else
      Model.SelLength := 0;
  end;
end;

procedure TCustomEdit.Loaded;
begin
  inherited;
  Model.TextSettingsInfo.Design := csDesigning in ComponentState;
end;

procedure TCustomEdit.GoToTextBegin;
begin
  CaretPosition := 0;
end;

procedure TCustomEdit.GoToTextEnd;
begin
  CaretPosition := Text.Length;
end;

function TCustomEdit.HasSelection: Boolean;
begin
  Result := Model.HasSelection;
end;

procedure TCustomEdit.HideCaret;
begin
  Caret.Hide;
end;

function TCustomEdit.GetImeMode: TImeMode;
begin
  Result := Model.ImeMode;
end;

function TCustomEdit.GetInputSupport: Boolean;
begin
  Result := Model.InputSupport;
end;

function TCustomEdit.GetItem(const AIndex: Integer): TFmxObject;
begin
  Result := FButtonsContent.Children[AIndex];
end;

function TCustomEdit.GetItemsCount: Integer;
begin
  Result := FButtonsContent.ChildrenCount;
end;

procedure TCustomEdit.SetImeMode(const Value: TImeMode);
begin
  Model.ImeMode := Value;
end;

procedure TCustomEdit.SetInputSupport(const Value: Boolean);
begin
  if Model.InputSupport <> Value then
  begin
    Model.InputSupport := Value;
    Caret.Visible := Model.InputSupport;
  end;
end;

procedure TCustomEdit.ButtonsChanged;
begin
  if HasPresentationProxy then
    PresentationProxy.SendMessage(MM_EDIT_EDITBUTTONS_CHANGED)
  else
    RealignButtonsContainer;
end;

function TCustomEdit.CanObserve(const ID: Integer): Boolean;
begin
  Result := False;
  if ID = TObserverMapping.EditLinkID then
    Result := True;
  if ID = TObserverMapping.ControlValueID then
    Result := True;
end;

procedure TCustomEdit.ObserverAdded(const ID: Integer; const Observer: IObserver);
begin
  if ID = TObserverMapping.EditLinkID then
    Observer.OnObserverToggle := ObserverToggle;
end;

procedure TCustomEdit.ObserverToggle(const AObserver: IObserver; const Value: Boolean);
var
  LEditLinkObserver: IEditLinkObserver;
  LEditFormatLink: IEditFormatLink;
begin
  if not Supports(AObserver, IEditLinkObserver, LEditLinkObserver) then
    Exit;

  if Value then
  begin
    FSavedReadOnly := ReadOnly;
    FSavedTextAlign := TextAlign;
    FSavedMaxLength := MaxLength;
    if LEditLinkObserver.IsReadOnly then
      ReadOnly := True;
    if Supports(LEditLinkObserver.FormatLink, IEditFormatLink, LEditFormatLink) then
    begin
      TextAlign := AlignmentToTTextAlign[LEditFormatLink.Alignment];
      MaxLength := LEditFormatLink.MaxLength;
    end;
  end
  else if not (csDestroying in ComponentState) then
  begin
    ReadOnly := FSavedReadOnly;
    TextAlign := FSavedTextAlign;
    MaxLength := FSavedMaxLength;
  end;
end;

procedure TCustomEdit.DoInsertObject(Index: Integer; const AObject: TFmxObject);
var
  EditControl: IEditControl;
begin
  if AObject.GetInterface(IEditControl, EditControl) then
  begin
    if ((FButtonsContent.Children <> nil) and not FButtonsContent.ContainsObject(AObject)) or
       (FButtonsContent.Children = nil) then
      FButtonsContent.InsertObject(Index, AObject);
    if AObject is TControl then
      TControl(AObject).Cursor := crArrow;
  end
  else
    inherited DoInsertObject(Index, AObject);
end;

procedure TCustomEdit.DoRemoveObject(const AObject: TFmxObject);
var
  EditControl: IEditControl;
begin
  if AObject.GetInterface(IEditControl, EditControl) and FButtonsContent.ContainsObject(AObject) then
    FButtonsContent.RemoveObject(AObject)
  else
    inherited DoRemoveObject(AObject);
end;

function TCustomEdit.GetText: string;
begin
  Result := Model.Text;
end;

procedure TCustomEdit.SetText(const Value: string);
begin
  if Model.Text <> Value then
  begin
    Model.Text := Value;
    Model.SelStart := 0;
    Model.SelLength := 0;
    Model.Change;
  end;
end;

procedure TCustomEdit.SetPassword(const Value: Boolean);
begin
  Model.Password := Value;
end;

procedure TCustomEdit.SetPromptText(const Prompt: string);
begin
  Model.TextPrompt := Prompt;
end;

function TCustomEdit.GetPromptText: string;
begin
  Result := Model.TextPrompt;
end;

function TCustomEdit.GetReadOnly: Boolean;
begin
  Result := Model.ReadOnly;
end;

procedure TCustomEdit.SetReadOnly(const Value: Boolean);
begin
  FSavedReadOnly := Value;
  Model.ReadOnly := Value;
  Caret.ReadOnly := Value;
end;

procedure TCustomEdit.SetReturnKeyType(Value: TReturnKeyType);
begin
  Model.ReturnKeyType := Value;
end;

procedure TCustomEdit.SetKeyboardType(Value: TVirtualKeyboardType);
begin
  Model.KeyboardType := Value;
end;

procedure TCustomEdit.SetKillFocusByReturn(const Value: Boolean);
begin
  Model.KillFocusByReturn := Value;
end;

{ TEditButton }

constructor TEditButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  SetAcceptsControls(False);
  Align := TAlignLayout.Left;
  CanFocus := False;
  Touch.InteractiveGestures := Touch.InteractiveGestures + [TInteractiveGesture.LongTap];
end;

function TEditButton.GetControl: TControl;
begin
  Result := Self;
end;

function TEditButton.GetDefaultSize: TSizeF;
begin
  Result := TSizeF.Create(28, 28);
end;

function TEditButton.GetDefaultStyleLookupName: string;
begin
  Result := 'buttonstyle'; // do not localize
end;

function TEditButton.GetEdit: TCustomEdit;
begin
  TFmxObjectHelper.FindNearestParentOfClass<TCustomEdit>(Self, Result);
end;

procedure TEditButton.SetName(const NewName: TComponentName);
begin
  inherited SetName(NewName);
  if NewName = Text then
    Text := string.Empty;
end;

{ TContentEdit }

constructor TContentEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  SetAcceptsControls(False);
end;

procedure TContentEdit.DoAddObject(const AObject: TFmxObject);
begin
  inherited;
  if (AObject is TCustomButton) and (Edit <> nil) then
    Edit.ButtonsChanged;
end;

procedure TContentEdit.DoInsertObject(Index: Integer; const AObject: TFmxObject);
begin
  inherited;
  if (AObject is TCustomButton) and (Edit <> nil) then
    Edit.ButtonsChanged;
end;

procedure TContentEdit.DoRemoveObject(const AObject: TFmxObject);
begin
  inherited;
  if (AObject is TCustomButton) and (Edit <> nil) then
    Edit.ButtonsChanged;
end;

function TContentEdit.GetEdit: TCustomEdit;
begin
  Result := ParentControl as TCustomEdit;
end;

{ TCustomEditModel }

function TCustomEditModel.CanSetFocus: Boolean;
begin
  Result := True;
  SendMessageWithResult<Boolean>(MM_EDIT_CAN_SET_FOCUS, Result);
end;

procedure TCustomEditModel.Change;
begin
  if FChanged then
  begin
    if not FValidating then
    begin
      FValidating := True;
      try
        Text := DoValidate(Text);
      finally
        FValidating := False;
      end;
    end;
    FChanged := False;
    try
      DoChange;
    finally
    end;
  end;
end;

constructor TCustomEditModel.Create;
begin
  inherited Create;
  FAutoSelect := DefaultAutoSelect;
  FTextSettingsInfo := TEditSettingsInfo.Create(Self, GetTextSettingsClass);
  FTextSettingsInfo.DefaultTextSettings.FontColor := DefaultFontColor;
  FInputSupport := DefaultInputSupport;
  FSelectionFill := TBrush.Create(TBrushKind.Solid, DefaultSelectionColor);
  FCaret := TCaret.Create(Owner as TFmxObject);
  FCaret.Visible := InputSupport;
  FCaret.ReadOnly := ReadOnly;
  FCharCase := DefaultCharCase;
  FHideSelectionOnExit := DefaultHideSelectionOnExit;
end;

procedure TCustomEditModel.DeleteFrom(const APosition: Integer; const ALength: Integer;
  const Options: TDeleteOptions);
var
  TmpS: string;
begin
  if Text.IsEmpty or (ALength <= 0) then
    Exit;

  if not InRange(APosition, 0, Text.Length) then
    raise EArgumentOutOfRangeException.CreateRes(@SCaretPosIncorrect);

  TmpS := Text.Substring(APosition, ALength);

  if TmpS.IsEmpty then
    Exit;

  if (TDeleteOption.CanUndo in Options) and (ALength > 0) then
    SendMessage<TFragmentDeleted>(PM_EDIT_UNDO_MANAGER_DELETE_TEXT, TFragmentDeleted.Create(APosition, TmpS,
      TDeleteOption.Selected in Options, TDeleteOption.MoveCaret in Options));

  TmpS := Text;
  Text := TmpS.Remove(APosition, ALength);
  if (TDeleteOption.MoveCaret in Options) or (SelLength <> 0) then
    CaretPosition := APosition;
end;

destructor TCustomEditModel.Destroy;
begin
  FreeAndNil(FSelectionFill);
  FreeAndNil(FCaret);
  FreeandNil(FTextSettingsInfo);
  inherited;
end;

procedure TCustomEditModel.DoChange;
begin
  if (Owner <> nil) and Assigned(FOnChange) and not (csLoading in Owner.ComponentState) then
    FOnChange(Owner);
end;

procedure TCustomEditModel.DoChangeTracking;
begin
  FChanged := True;
  SendMessage(MM_EDIT_TEXT_CHANGING);
  if Assigned(FOnChangeTracking) and not (csLoading in Owner.ComponentState) then
    FOnChangeTracking(Owner);
end;

function TCustomEditModel.DoFiltering(const Value: string): string;
begin
  Result := FilterText(Value, FilterChar);
end;

function TCustomEditModel.DoTruncating(const Value: string): string;
var
  SeparatorIndex: Integer;
begin
  SeparatorIndex := Value.IndexOfAny([#10, #13]);
  if SeparatorIndex >= 0 then
    Result := Value.Substring(0, SeparatorIndex)
  else
    Result := Value;

  Result := TruncateText(Result, MaxLength);
end;

function TCustomEditModel.DoValidating(const Value: string): string;
begin
  case FCharCase of
    TEditCharCase.ecUpperCase:
      Result := Value.ToUpper;
    TEditCharCase.ecLowerCase:
      Result := Value.ToLower;
    else
      Result := Value;
  end;
  if (Owner <> nil) and (Owner is TCustomEdit) and Assigned(FOnValidating) and not (csLoading in Owner.ComponentState) then
    FOnValidating(Owner, Result);
end;

function TCustomEditModel.DoValidate(const Value: string): string;
begin
  Result := TruncateText(FilterText(Value, FilterChar), MaxLength);
  if (Owner <> nil) and (Owner is TCustomEdit) and Assigned(FOnValidate) and not (csLoading in Owner.ComponentState) then
    FOnValidate(Owner, Result);
end;

function TCustomEditModel.GetCaretPositionByPoint(const AHitPoint: TPointF): Integer;
var
  Message: TGetCaretPositionInfo;
begin
  Message.HitPoint := AHitPoint;
  Message.CaretPosition := -1;
  SendMessageWithResult<TGetCaretPositionInfo>(MM_EDIT_GET_CARET_POSITION_BY_POINT, Message);
  Result := Message.CaretPosition;
end;

function TCustomEditModel.GetCount: Integer;
begin
  Result := 1;
end;

function TCustomEditModel.GetLine(const ALineIndex: Integer): string;
begin
  Result := Text;
end;

function TCustomEditModel.GetLineBreak: string;
begin
  Result := SLineBreak;
end;

function TCustomEditModel.GetNextWordBegin(const APosition: Integer): Integer;
begin
  if Text.IsEmpty then
    Exit(APosition);

  if APosition < Text.Length then
    Result := GetNextLexemeBegin(Text, APosition)
  else
    Result := APosition;
end;

function TCustomEditModel.GetPositionShift(const APosition, ADelta: Integer): Integer;
begin
  Result := EnsureRange(APosition + ADelta, 0, Text.Length);
end;

function TCustomEditModel.GetPrevWordBegin(const APosition: Integer): Integer;
begin
  if Text.IsEmpty then
    Exit(APosition);

  if APosition > 0 then
    Result := GetPrevLexemeBegin(Text, APosition)
  else
    Result := APosition;
end;

function TCustomEditModel.GetText: string;
begin
  Result := FText;
end;

function TCustomEditModel.GetTextSettingsClass: TTextSettingsInfo.TCustomTextSettingsClass;
begin
  Result := TEditTextSettings;
end;

function TCustomEditModel.HasSelection: Boolean;
begin
  Result := Abs(SelLength) > 0;
end;

procedure TCustomEditModel.InsertAfter(const APosition: Integer; const AFragment: string;
  const Options: TInsertOptions);

  procedure NormalizeText(var AFragment: string);
  begin
    case CharCase of
      TEditCharCase.ecUpperCase:
        AFragment := AFragment.ToUpper;
      TEditCharCase.ecLowerCase:
        AFragment := AFragment.ToLower;
    end;

    if MaxLength > 0 then
      AFragment := AFragment.Substring(0, MaxLength - Text.Length);
  end;

var
  Insertion: string;
  TmpS: string;
  LPosition: Integer;
  SavedCaretPosition: Integer;
  WasCaretPositionChangedByUser: Boolean;
begin
  if APosition < 0 then
    raise EArgumentOutOfRangeException.CreateRes(@SCaretPosIncorrect);

  Insertion := AFragment;
  NormalizeText(Insertion);
  if Insertion.IsEmpty then
    Exit;

  LPosition := EnsureRange(APosition, 0, Text.Length);
  if TInsertOption.CanUndo in Options then
    SendMessage<TFragmentInserted>(PM_EDIT_UNDO_MANAGER_INSERT_TEXT, TFragmentInserted.Create(LPosition,
      Insertion, TInsertOption.UndoPairedWithPrev in Options, TInsertOption.Typed in Options));
  TmpS := FText;
  SavedCaretPosition := CaretPosition;
  Text := TmpS.Insert(LPosition, Insertion);
  WasCaretPositionChangedByUser := SavedCaretPosition <> CaretPosition;
  if TInsertOption.Selected in Options then
  begin
    SelStart := APosition;
    SelLength := Insertion.Length;
    if TInsertOption.MoveCaret in Options then
      CaretPosition := SelStart + SelLength;
  end
  else if not (csLoading in Owner.ComponentState) and (TInsertOption.MoveCaret in Options) and not WasCaretPositionChangedByUser then
    CaretPosition := LPosition + Insertion.Length;
end;

procedure TCustomEditModel.MoveCaretHorizontal(const ADelta: Integer);
begin
  CaretPosition := EnsureRange(CaretPosition + ADelta, 0, Text.Length);
end;

procedure TCustomEditModel.MoveCaretLeft;
var
  Offset: Integer;
begin
  if Text.IsEmpty then
    Exit;

  if (CaretPosition > 0) and Text.Chars[CaretPosition - 1].IsLowSurrogate then
    Offset := -2
  else
    Offset := -1;

  MoveCaretHorizontal(Offset);
end;

procedure TCustomEditModel.MoveCaretRight;
var
  Offset: Integer;
begin
  if Text.IsEmpty then
    Exit;

  if (Text.Length > CaretPosition) and Text.Chars[CaretPosition].IsLowSurrogate then
    Offset := 2
  else
    Offset := 1;

  MoveCaretHorizontal(Offset);
end;

function TCustomEditModel.PosToTextPos(const APosition: TCaretPosition): Integer;
begin
  Result := APosition.Pos;
end;

function TCustomEditModel.SelectedText: string;
begin
  if SelLength < 0 then
    Result := Text.Substring(SelStart - Abs(SelLength), Abs(SelLength))
  else if SelLength > 0 then
    Result := Text.Substring(SelStart, SelLength)
  else
    Result := string.Empty;
end;

procedure TCustomEditModel.SetAutoSelect(const Value: Boolean);
begin
  if FAutoSelect <> Value then
  begin
    FAutoSelect := Value;
    SendMessage(MM_EDIT_AUTOSELECT_CHANGED);
  end;
end;

procedure TCustomEditModel.SetCaret(const Value: TCustomCaret);
begin
  FCaret.Assign(Value);
  SendMessage(MM_EDIT_CARETCHANGED);
end;

procedure TCustomEditModel.SetCaretPosition(const Value: Integer);
begin
  FCaretPosition := EnsureRange(Value, 0, Text.Length);
  SendMessage<Integer>(MM_EDIT_CARETPOSITION_CHANGED, Value);
end;

procedure TCustomEditModel.SetCheckSpelling(const Value: Boolean);
begin
  if FCheckSpelling <> Value then
  begin
    FCheckSpelling := Value;
    SendMessage<Boolean>(MM_EDIT_CHECKSPELLING_CHANGED, Value);
  end;
end;

procedure TCustomEditModel.SetFilterChar(const Value: string);
var
  OldText: string;
begin
  if FFilterChar <> Value then
  begin
    FFilterChar := Value;
    SendMessage<string>(MM_EDIT_FILTERCHAR_CHANGED, Value);
    OldText := FText;
    FText := DoValidating(TruncateText(FilterText(FText, FilterChar), MaxLength));
    if FText <> OldText then
    begin
      DoChangeTracking;
      SendMessage<string>(MM_EDIT_TEXT_CHANGED, FText);
      Change;
    end;
  end;
end;

procedure TCustomEditModel.SetHideSelectionOnExit(const Value: Boolean);
begin
  if FHideSelectionOnExit <> Value then
  begin
    FHideSelectionOnExit := Value;
    SendMessage(MM_EDIT_HIDESELECTIONONEXIT_CHANGED);
  end;
end;

procedure TCustomEditModel.SetCharCase(const Value: TEditCharCase);
begin
  if FCharCase <> Value then
  begin
    FCharCase := Value;
    case FCharCase of
      TEditCharCase.ecUpperCase:
        Text := Text.ToUpper;
      TEditCharCase.ecLowerCase:
        Text := Text.ToLower;
    end;
    SendMessage<TEditCharCase>(MM_EDIT_CHARCASE_CHANGED, Value);
  end;
end;

procedure TCustomEditModel.SetImeMode(const Value: TImeMode);
begin
  if FImeMode <> Value then
  begin
    FImeMode := Value;
    SendMessage<TImeMode>(MM_EDIT_IMEMODE_CHANGED, Value);
  end;
end;

procedure TCustomEditModel.SetKeyboardType(const Value: TVirtualKeyboardType);
begin
  if FKeyboardType <> Value then
  begin
    FKeyboardType := Value;
    SendMessage<TVirtualKeyboardType>(MM_EDIT_KEYBOARDTYPE_CHANGED, Value);
  end;
end;

procedure TCustomEditModel.SetKillFocusByReturn(const Value: Boolean);
begin
  if FKillFocusByReturn <> Value then
  begin
    FKillFocusByReturn := Value;
    SendMessage<Boolean>(MM_EDIT_KILLFOCUSBYRETURN_CHANGED, Value);
  end;
end;

procedure TCustomEditModel.SetMaxLength(const Value: Integer);
begin
  if MaxLength <> Value then
  begin
    FMaxLength := Max(0, Value);
    Text := TruncateText(Text, FMaxLength);
    Change;
    SendMessage<Integer>(MM_EDIT_MAXLENGTH_CHANGED, Value);
  end;
end;

procedure TCustomEditModel.SetPassword(const Value: Boolean);
begin
  if FPassword <> Value then
  begin
    FPassword := Value;
    SendMessage<Boolean>(MM_EDIT_ISPASSWORD_CHANGED, Value);
  end;
end;

procedure TCustomEditModel.SetReadOnly(const Value: Boolean);
begin
  if FReadOnly <> Value then
  begin
    FReadOnly := Value;
    FCaret.ReadOnly := Value;
    SendMessage<Boolean>(MM_EDIT_READONLY_CHANGED, Value);
  end;
end;

procedure TCustomEditModel.SetReturnKeyType(const Value: TReturnKeyType);
begin
  if FReturnKeyType <> Value then
  begin
    FReturnKeyType := Value;
    SendMessage<TReturnKeyType>(MM_EDIT_RETURNKEYTYPE_CHANGED, Value);
  end;
end;

procedure TCustomEditModel.SetSelLength(const Value: Integer);
begin
  if FSelLength <> Value then
  begin
    FSelLength := Value;
    SendMessage<Integer>(MM_EDIT_SELLENGTH_CHANGED, Value);
  end;
end;

procedure TCustomEditModel.SetSelStart(const Value: Integer);
begin
  if FSelStart <> Value then
  begin
    FSelStart := EnsureRange(Value, 0, Text.Length);
    SendMessage<Integer>(MM_EDIT_SELSTART_CHANGED, Value);
  end;
end;

procedure TCustomEditModel.SetText(const Value: string);
var
  OldText: string;
begin
  if Text <> Value then
  begin
    OldText := FText;
    FText := DoValidating(DoTruncating(DoFiltering(Value)));
    if FText <> OldText then
    begin
      DoChangeTracking;
      SendMessage<string>(MM_EDIT_TEXT_CHANGED, FText);
    end;
  end;
end;

procedure TCustomEditModel.SetSelectionFill(const Value: TBrush);
begin
  FSelectionFill.Assign(Value);
end;

procedure TCustomEditModel.SetTextPrompt(const Value: string);
begin
  if FTextPrompt <> Value then
  begin
    FTextPrompt := Value;
    SendMessage<string>(MM_EDIT_PROMPTTEXT_CHANGED, Value);
  end;
end;

procedure TCustomEditModel.SetTextWithoutValidation(const Value: string);
begin
  if Text <> Value then
  begin
    case FCharCase of
      TEditCharCase.ecUpperCase:
        FText := Value.ToUpper;
      TEditCharCase.ecLowerCase:
        FText := Value.ToLower;
    else
      FText := Value;
    end;
    DoChangeTracking;
  end;
end;

procedure TCustomEditModel.SetTyping(const Value: Boolean);
begin
  if FTyping <> Value then
  begin
    FTyping := Value;
    SendMessage(MM_EDIT_TYPING_CHANGED);
  end;
end;

function TCustomEditModel.TextPosToPos(const APos: Integer): TCaretPosition;
begin
  Result := TCaretPosition.Create(0, APos);
end;

procedure TCustomEditModel.Replace(const APosition, ALength: Integer; const AFragment: string);
var
  TmpS: string;
begin
  if not InRange(APosition, 0, Text.Length - 1) then
    raise EArgumentOutOfRangeException.CreateRes(@SCaretPosIncorrect);

  TmpS := Text;
  Text := TmpS.Remove(APosition, ALength).Insert(APosition, AFragment);
end;

procedure TCustomEditModel.ResultTextSettingsChanged;
begin
  SendMessage(MM_EDIT_TEXT_SETTINGS_CHANGED);
end;

{ TClearEditButton }

procedure TClearEditButton.Click;
var
  EditTmp: TCustomEdit;
begin
  inherited Click;
  EditTmp := GetEdit;
  if EditTmp <> nil then
  begin
    if EditTmp.Observers.IsObserving(TObserverMapping.EditLinkID) then
      if not TLinkObservers.EditLinkEdit(EditTmp.Observers) then
        Exit; // Can't change
    
    // 使用DeleteFrom方法清空文本，这样会正确更新撤销管理器
    if EditTmp.Text.Length > 0 then
    begin
      // 删除整个文本，确保撤销管理器记录这个操作
      EditTmp.Model.DeleteFrom(0, EditTmp.Text.Length, 
        [TDeleteOption.CanUndo, TDeleteOption.MoveCaret]);
      // 错误方法，反面教材
      // EditTmp.Replace(0, EditTmp.Text.Length, '');
    end;
    
    if EditTmp.Observers.IsObserving(TObserverMapping.EditLinkID) then
      TLinkObservers.EditLinkModified(EditTmp.Observers);
    if EditTmp.Observers.IsObserving(TObserverMapping.ControlValueID) then
      TLinkObservers.ControlValueModified(EditTmp.Observers);
  end;
end;

function TClearEditButton.GetDefaultStyleLookupName: string;
begin
  Result := 'cleareditbutton';
end;

{ TPasswordEditButton }

function TPasswordEditButton.GetDefaultStyleLookupName: string;
begin
  Result := 'passwordeditbutton';
end;

procedure TPasswordEditButton.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
  EditTmp: TCustomEdit;
begin
  inherited MouseDown(Button, Shift, X, Y);
  EditTmp := GetEdit;
  if EditTmp <> nil then
    EditTmp.Password := False;
end;

procedure TPasswordEditButton.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
  EditTmp: TCustomEdit;
begin
  inherited MouseUp(Button, Shift, X, Y);;
  EditTmp := GetEdit;
  if EditTmp <> nil then
    EditTmp.Password := True;
end;

{ TSearchEditButton }

function TSearchEditButton.GetDefaultStyleLookupName: string;
begin
  Result := 'searcheditbutton';
end;

{ TEllipsesEditButton }

function TEllipsesEditButton.GetDefaultStyleLookupName: string;
begin
  Result := 'ellipseseditbutton';
end;

{ TDropDownEditButton }

function TDropDownEditButton.GetDefaultStyleLookupName: string;
begin
  Result := 'dropdowneditbutton';
end;

{ TSpinEditButton }

procedure TSpinEditButton.ApplyStyle;
begin
  inherited ApplyStyle;
  if FindStyleResource<TCustomButton>('upbutton', FUpButton) then
  begin
    FUpButton.TouchTargetExpansion.Bottom := 0;
    FUpButton.RepeatClick := FRepeatClick;
    FUpButton.OnClick := DoUpButtonClick;
  end;
  if FindStyleResource<TCustomButton>('downbutton', FDownButton) then
  begin
    FDownButton.TouchTargetExpansion.Top := 0;
    FDownButton.RepeatClick := FRepeatClick;
    FDownButton.OnClick := DoDownButtonClick;
  end;
end;

constructor TSpinEditButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Align := TAlignLayout.Left;
  CanFocus := False;
end;

function TSpinEditButton.GetDefaultSize: TSizeF;
begin
  Result := TSizeF.Create(20, 28);
end;

function TSpinEditButton.GetDefaultStyleLookupName: string;
begin
  Result := 'spineditbutton';
end;

procedure TSpinEditButton.SetRepeatClick(const Value: Boolean);
begin
  if FRepeatClick <> Value then
  begin
    FRepeatClick := Value;
    if FUpButton <> nil then
      FUpButton.RepeatClick := FRepeatClick;
    if FDownButton <> nil then
      FDownButton.RepeatClick := FRepeatClick;
  end;
end;

procedure TSpinEditButton.DoDownButtonClick(Sender: TObject);
begin
  if Assigned(FOnDownClick) then
    FOnDownClick(Self);
end;

procedure TSpinEditButton.DoUpButtonClick(Sender: TObject);
begin
  if Assigned(FOnUpClick) then
    FOnUpClick(Self);
end;

procedure TSpinEditButton.FreeStyle;
begin
  if FUpButton <> nil then
    FUpButton.OnClick := nil;
  FUpButton := nil;
  if FDownButton <> nil then
    FDownButton.OnClick := nil;
  FDownButton := nil;
  inherited FreeStyle;
end;

function TSpinEditButton.GetControl: TControl;
begin
  Result := Self;
end;

{ TClearingEdit }

constructor TClearingEdit.Create(AOwner: TComponent);
var
  ClearButton: TClearEditButton;
begin
  inherited;
  ClearButton := TClearEditButton.Create(nil);
  ClearButton.Stored := False;
  ClearButton.Lock;
  ClearButton.Parent := Self;
end;

function TClearingEdit.DefinePresentationName: string;
begin
  Result := 'Edit-' + GetPresentationSuffix;
end;

function TClearingEdit.GetDefaultStyleLookupName: string;
begin
  Result := 'editstyle';
end;

initialization
{$WARNINGS OFF}
  RegisterFmxClasses([TEdit, TClearEditButton, TPasswordEditButton, TSearchEditButton, TEllipsesEditButton,
    TDropDownEditButton, TEditButton, TSpinEditButton, TClearingEdit]);
{$WARNINGS ON}
end.
