unit mainForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, ComCtrls, StdCtrls, ActnList, Menus, RTTICtrls,
  MPlayerCtrl;

type

  { TfrmMain }

  TfrmMain = class(TForm)
    aclAkce: TActionList;
    acPlay: TAction;
    acStop: TAction;
    acPause: TAction;
    acAdd: TAction;
    acClearList: TAction;
    acUpdate: TAction;
    acDelete: TAction;
    btnClearList: TButton;
    btnPlay: TButton;
    btnStop: TButton;
    btnPause: TButton;
    btnAdd: TButton;
    btnUpdate: TButton;
    btnDelete: TButton;
    lblTime: TLabel;
    lbTimePoints: TListBox;
    poiPlay: TMenuItem;
    poiStop: TMenuItem;
    poiPause: TMenuItem;
    poiAdd: TMenuItem;
    poiSeparator: TMenuItem;
    poiUpdate: TMenuItem;
    poiDelete: TMenuItem;
    poiClearList: TMenuItem;
    MPlayer: TMPlayerControl;
    pomAkce: TPopupMenu;
    trbAudio: TTITrackBar;
    trbProgress: TTrackBar;
    procedure acAddExecute(Sender: TObject);
    procedure acClearListExecute(Sender: TObject);
    procedure acDeleteExecute(Sender: TObject);
    procedure acPauseExecute(Sender: TObject);
    procedure acPlayExecute(Sender: TObject);
    procedure acStopExecute(Sender: TObject);
    procedure acUpdateExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure MPlayerPlaying(ASender: TObject; APosition: single);
    procedure trbAudioChange(Sender: TObject);
    procedure trbProgressChange(Sender: TObject);
    procedure trbProgressMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X,
      Y: Integer);
    procedure trbProgressMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X,
      Y: Integer);
  private

  public

  end;

var
  frmMain: TfrmMain;

implementation

{$R *.lfm}

{ TfrmMain }

var
    changingPosition :Boolean = false;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  {$IFDEF Linux}
  MPlayer.StartParam := '-vo x11 -zoom -fs';
  {$else $IFDEF Windows}
  MPlayer.StartParam := '-vo direct3d -nofontconfig';
  {$ENDIF}
  MPlayer.Volume:= 50;
  MPlayer.Filename := IncludeTrailingBackslash(ExtractFileDir(Application.ExeName)) +
                      IncludeTrailingBackSlash('video_example') + 'sample-mp4-file.mp4';
  lbTimePoints.Sorted:= True;
end;

procedure TfrmMain.MPlayerPlaying(ASender: TObject; APosition: single);
begin
  if (MPlayer.Duration <> 0) then
      begin
        changingPosition:= true;
        lblTime.Caption :=  FormatDateTime('h:nnn:ss', APosition / (24 * 60 * 60)) + ' / ' +
                            FormatDateTime('h:nnn:ss', MPlayer.Duration / (24 * 60 * 60));
        trbProgress.Position:=  trunc(APosition / MPlayer.Duration * 100);
        Application.ProcessMessages;
        //ShowMessage(Format('%f',[APosition / MPlayer.Duration]));
        changingPosition:= false;
      end;
end;

procedure TfrmMain.trbAudioChange(Sender: TObject);
begin
  MPlayer.Volume:= trbAudio.Position;
end;

procedure TfrmMain.trbProgressChange(Sender: TObject);
var
  newPosition: Single;
begin
   if not changingPosition then
       begin
         newPosition :=  trbProgress.Position/100 * MPlayer.Duration;
         lblTime.Caption :=  FormatDateTime('h:nnn:ss', newPosition / (24 * 60 * 60)) + ' / ' +
                             FormatDateTime('h:nnn:ss', MPlayer.Duration / (24 * 60 * 60));
         MPlayer.Position:= newPosition;
       end;

   // alternative solution maybe using pause of mPlayer when onMouseDown and unpause when onMouseUp
   // not alternative but suplementary :-)

end;

procedure TfrmMain.trbProgressMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  if btnPause.Caption = 'Pause' then
     MPlayer.Paused:= true;
end;

procedure TfrmMain.trbProgressMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  if btnPause.Caption = 'Pause' then
     MPlayer.Paused:= false;
end;

procedure TfrmMain.acPlayExecute(Sender: TObject);
begin
  if not MPlayer.Paused then
   MPlayer.Play;
end;

procedure TfrmMain.acPauseExecute(Sender: TObject);
begin
  MPlayer.Paused:= not MPlayer.Paused;
  if MPlayer.Paused then
   begin
      btnPause.Caption:= 'P A U S E D';
      acPlay.Enabled:= not acPlay.Enabled;
   end
  else
   begin
      btnPause.Caption:= 'Pause';
      acPlay.Enabled:= not acPlay.Enabled;
   end;
end;

procedure TfrmMain.acAddExecute(Sender: TObject);
begin
  lbTimePoints.Items.Append(FormatDateTime('h:nnn:ss', MPlayer.Position / (24 * 60 * 60)));
end;

procedure TfrmMain.acClearListExecute(Sender: TObject);
begin
   lbTimePoints.Items.Clear;
end;

procedure TfrmMain.acDeleteExecute(Sender: TObject);
var
  i: Integer;
begin
  if lbTimePoints.ItemIndex <> -1 then
      begin
        for i:= lbTimePoints.Count - 1 downto 0 do
          if lbTimePoints.Selected[i] then
            lbTimePoints.Items.Delete(lbTimePoints.ItemIndex);
          lbTimePoints.ClearSelection;
      end;
end;

procedure TfrmMain.acStopExecute(Sender: TObject);
begin
  MPlayer.Stop;
  lblTime.Caption:= 'H:MM:SS / H:MM:SS';
  trbProgress.Position:= 0;
end;

procedure TfrmMain.acUpdateExecute(Sender: TObject);
var
   pom : Integer;
begin
  if lbTimePoints.ItemIndex <> -1 then
      begin
        pom:= lbTimePoints.ItemIndex;
        lbTimePoints.ClearSelection;
        lbTimePoints.Sorted:= false;
        lbTimePoints.Items.Strings[pom] := FormatDateTime(
                                                    'h:nnn:ss', MPlayer.Position / (24 * 60 * 60));
        lbTimePoints.Sorted:=True;
        lbTimePoints.ItemIndex:= pom;
      end;
end;

end.

