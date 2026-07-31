unit Utama;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls, LCLType, Types;

type

  { TMain }

  TMain = class(TForm)
    ButtonMulai: TButton;
    ButtonReset: TButton;
    GameCanvas: TImage;
    LabelPlayer: TLabel;
    LabelAI: TLabel;
    ShapePaddle1: TShape;
    ShapePaddle2: TShape;
    ShapeBall: TShape;
    Timer1: TTimer;
    procedure ButtonMulaiClick(Sender: TObject);
    procedure ButtonResetClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Timer1Timer(Sender: TObject);
  private

  public
    BallDX, BallDY: Integer;
    PaddleSpeed: Integer;
    UpPressed, DownPressed: Boolean;
    PlayerScore, AIScore: Integer;
    procedure ResetGame;
    procedure UpdateScoreLabel;
  end;

var
  Main: TMain;

implementation

{$R *.lfm}

{ TMain }

procedure TMain.FormCreate(Sender: TObject);
begin
  Randomize; // Biar arah bola benar-benar acak
  PaddleSpeed := 6;
  BallDX := 4;
  BallDY := 4;

  PlayerScore := 0;
  AIScore := 0;

  GameCanvas.Color := clWhite;

  // Tambahkan border hitam di sekitar GameCanvas
  GameCanvas.Canvas.Pen.Color := clBlack;
  GameCanvas.Canvas.Brush.Style := bsClear;
  GameCanvas.Canvas.Rectangle(0, 0, GameCanvas.Width, GameCanvas.Height);

  Timer1.Enabled := False; // Game tidak langsung mulai
  ResetGame;
end;

procedure TMain.ButtonMulaiClick(Sender: TObject);
begin
  Timer1.Enabled := True;        // Aktifkan timer game
  ButtonMulai.Enabled := False;     // Nonaktifkan tombol setelah klik
end;

procedure TMain.ButtonResetClick(Sender: TObject);
begin
  PlayerScore := 0;
  AIScore := 0;
  ResetGame;
  Timer1.Enabled := True;        // Mulai ulang game langsung
  ButtonMulai.Enabled := False;     // Nonaktifkan tombol mulai (opsional)
end;

procedure TMain.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState
  );
begin
  if Key = VK_UP then UpPressed := True;
  if Key = VK_DOWN then DownPressed := True;
end;

procedure TMain.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_UP then UpPressed := False;
  if Key = VK_DOWN then DownPressed := False;
end;

procedure TMain.Timer1Timer(Sender: TObject);
var
    BallRect, Paddle1Rect, Paddle2Rect, IntersectArea: TRect;
begin
 // Gerakkan paddle player
  if UpPressed and (ShapePaddle1.Top > GameCanvas.Top) then
    ShapePaddle1.Top := ShapePaddle1.Top - PaddleSpeed;
  if DownPressed and (ShapePaddle1.Top + ShapePaddle1.Height < GameCanvas.Top + GameCanvas.Height) then
    ShapePaddle1.Top := ShapePaddle1.Top + PaddleSpeed;

  // Gerakkan paddle AI
  if ShapeBall.Top + ShapeBall.Height div 2 < ShapePaddle2.Top + ShapePaddle2.Height div 2 then
    ShapePaddle2.Top := ShapePaddle2.Top - (PaddleSpeed - 3);
  if ShapeBall.Top + ShapeBall.Height div 2 > ShapePaddle2.Top + ShapePaddle2.Height div 2 then
    ShapePaddle2.Top := ShapePaddle2.Top + (PaddleSpeed - 3);

  // Batas paddle AI
  if ShapePaddle2.Top < GameCanvas.Top then
    ShapePaddle2.Top := GameCanvas.Top;
  if ShapePaddle2.Top + ShapePaddle2.Height > GameCanvas.Top + GameCanvas.Height then
    ShapePaddle2.Top := GameCanvas.Top + GameCanvas.Height - ShapePaddle2.Height;

  // Gerakkan bola
  ShapeBall.Left := ShapeBall.Left + BallDX;
  ShapeBall.Top := ShapeBall.Top + BallDY;

  // Pantulan atas/bawah
  if (ShapeBall.Top <= GameCanvas.Top) or
     (ShapeBall.Top + ShapeBall.Height >= GameCanvas.Top + GameCanvas.Height) then
    BallDY := -BallDY;

  // Deteksi tabrakan paddle
  BallRect := ShapeBall.BoundsRect;
  Paddle1Rect := ShapePaddle1.BoundsRect;
  Paddle2Rect := ShapePaddle2.BoundsRect;

  if IntersectRect(IntersectArea, BallRect, Paddle1Rect) then
    BallDX := Abs(BallDX);
  if IntersectRect(IntersectArea, BallRect, Paddle2Rect) then
    BallDX := -Abs(BallDX);

  // Cek skor
  if ShapeBall.Left < GameCanvas.Left then
  begin
    Inc(AIScore);
    ResetGame;
  end
  else if ShapeBall.Left + ShapeBall.Width > GameCanvas.Left + GameCanvas.Width then
  begin
    Inc(PlayerScore);
    ResetGame;
  end;

  UpdateScoreLabel;
end;

procedure TMain.ResetGame;
begin
   // Posisi bola ke tengah
   ShapeBall.Left := GameCanvas.Left + GameCanvas.Width div 2 - ShapeBall.Width div 2;
   ShapeBall.Top := GameCanvas.Top + GameCanvas.Height div 2 - ShapeBall.Height div 2;

   // Posisi paddle ke tengah
   ShapePaddle1.Top := GameCanvas.Top + GameCanvas.Height div 2 - ShapePaddle1.Height div 2;
   ShapePaddle2.Top := GameCanvas.Top + GameCanvas.Height div 2 - ShapePaddle2.Height div 2;

   ShapePaddle1.Left := GameCanvas.Left + 20;
   ShapePaddle2.Left := GameCanvas.Left + GameCanvas.Width - ShapePaddle2.Width - 20;

   // Arah bola random ke kiri atau kanan
   if Random(2) = 0 then
     BallDX := -4
   else
     BallDX := 4;

   // Arah vertikal acak
   BallDY := Random(3) + 2; // 2 sampai 4
   if Random(2) = 0 then
     BallDY := -BallDY;

   UpdateScoreLabel;
end;

procedure TMain.UpdateScoreLabel;
begin
  LabelPlayer.Caption := 'Player: ' + IntToStr(PlayerScore);
  LabelAI.Caption := 'AI: ' + IntToStr(AIScore);
end;

end.

