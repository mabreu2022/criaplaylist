unit UnitPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, Winapi.ActiveX, Winapi.MMSystem,
  System.SysUtils, System.Variants, System.Classes, System.IOUtils,
  System.Types, System.Generics.Collections, System.Generics.Defaults,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ComCtrls;

// Declarações da Windows Media Foundation para obter a duração do áudio/vídeo
const
  MF_SDK_VERSION = $0002;
  MF_API_VERSION = $0070;
  MF_VERSION = (MF_SDK_VERSION shl 16) or MF_API_VERSION;
  MFSTARTUP_NOSOCKET = 1;
  MF_SOURCE_READER_MEDIASOURCE = $FFFFFFFF;

type
  IMFSourceReader = interface(IUnknown)
    ['{70AE66F2-C809-4E4F-8915-BDCB406B7993}']
    function GetStreamSelection(dwStreamIndex: DWORD; out pfSelected: BOOL): HResult; stdcall;
    function SetStreamSelection(dwStreamIndex: DWORD; fSelected: BOOL): HResult; stdcall;
    function GetNativeMediaType(dwStreamIndex: DWORD; dwMediaTypeIndex: DWORD; out ppMediaType: IUnknown): HResult; stdcall;
    function GetCurrentMediaType(dwStreamIndex: DWORD; out ppMediaType: IUnknown): HResult; stdcall;
    function SetCurrentMediaType(dwStreamIndex: DWORD; pdwReserved: PDWORD; pMediaType: IUnknown): HResult; stdcall;
    function SetCurrentPosition(const guidTimeFormat: TGUID; const varPosition: TPropVariant): HResult; stdcall;
    function ReadSample(dwStreamIndex: DWORD; dwControlFlags: DWORD; out pdwActualStreamIndex: DWORD;
      out pdwStreamFlags: DWORD; out pllTimestamp: Int64; out ppSample: IUnknown): HResult; stdcall;
    function Flush(dwStreamIndex: DWORD): HResult; stdcall;
    function GetServiceForStream(dwStreamIndex: DWORD; const guidService: TGUID; const riid: TGUID; out ppvObject: Pointer): HResult; stdcall;
    function GetPresentationAttribute(dwStreamIndex: DWORD; const guidKey: TGUID; out pvarAttribute: TPropVariant): HResult; stdcall;
  end;

function MFStartup(version: ULONG; dwFlags: DWORD = MFSTARTUP_NOSOCKET): HResult; stdcall; external 'mfplat.dll';
function MFShutdown: HResult; stdcall; external 'mfplat.dll';
function MFCreateSourceReaderFromURL(pwszURL: LPCWSTR; pAttributes: Pointer; out ppSourceReader: IMFSourceReader): HResult; stdcall; external 'mfreadwrite.dll';
function PropVariantClear(var pvar: TPropVariant): HResult; stdcall; external 'ole32.dll';

const
  MF_PD_DURATION: TGUID = '{6c9b5177-4e60-41fb-80fc-57381e494797}';

type
  TForm1 = class(TForm)
    // Seção 1: Criação de .ROT (Rotações com faixas de áudio)
    lblPasta: TLabel;
    lblDisponiveis: TLabel;
    lblPlaylist: TLabel;
    edtPasta: TEdit;
    btnSelecionarPasta: TButton;
    lbDisponiveis: TListBox;
    btnAdicionar: TButton;
    btnAdicionarTodos: TButton;
    btnRemover: TButton;
    btnRemoverTodos: TButton;
    lbPlaylist: TListBox;
    btnSalvarPlaylist: TButton;

    // Player de Áudio integrado
    btnPlay: TButton;
    btnPause: TButton;
    btnStop: TButton;
    lblPlayerStatus: TLabel;

    // Seção 2: Montagem de Playlist Master .LST (.ROT + Comandos)
    lblPlaylistLst: TLabel;
    lblPreviewLst: TLabel;
    lbPlaylistLst: TListBox;
    MemoPreviewLst: TMemo;
    btnBuscarRot: TButton;
    btnAdicionarHora: TButton;
    btnLimparLst: TButton;
    btnSubirLst: TButton;
    btnDescerLst: TButton;
    btnRemoverItemLst: TButton;
    btnSalvarLst: TButton;

    // Status e Logs
    ProgressBar1: TProgressBar;
    MemoLog: TMemo;

    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnSelecionarPastaClick(Sender: TObject);
    procedure btnAdicionarClick(Sender: TObject);
    procedure btnAdicionarTodosClick(Sender: TObject);
    procedure btnRemoverClick(Sender: TObject);
    procedure btnRemoverTodosClick(Sender: TObject);
    procedure btnSalvarPlaylistClick(Sender: TObject);
    procedure lbDisponiveisDblClick(Sender: TObject);
    procedure lbPlaylistDblClick(Sender: TObject);

    // Eventos do Player
    procedure btnPlayClick(Sender: TObject);
    procedure btnPauseClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);

    // Eventos da Seção .LST
    procedure btnBuscarRotClick(Sender: TObject);
    procedure btnAdicionarHoraClick(Sender: TObject);
    procedure btnLimparLstClick(Sender: TObject);
    procedure btnSubirLstClick(Sender: TObject);
    procedure btnDescerLstClick(Sender: TObject);
    procedure btnRemoverItemLstClick(Sender: TObject);
    procedure btnSalvarLstClick(Sender: TObject);
  private
    FPlayerTocando: Boolean;
    FPlayerPausado: Boolean;
    FPlayRequestId: Integer;
    FScanRequestId: Integer;
    function ObterDuracaoMP3_MS(const CaminhoArquivo: string): Int64;
    procedure CarregarArquivosDiretorio(const Pasta: string);
    procedure AtualizarPreviewLst;
    procedure TocarAudio(const Caminho: string);
    procedure PararAudio;
  public
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
begin
  CoInitialize(nil);
  MFStartup(MF_VERSION);
  MemoLog.Clear;
  FPlayerTocando := False;
  FPlayerPausado := False;
  FPlayRequestId := 0;
  FScanRequestId := 0;
  try
    Icon.Handle := LoadIcon(HInstance, 'MAINICON');
  except
  end;
  AtualizarPreviewLst;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  PararAudio;
  MFShutdown;
  CoUninitialize;
end;

function TForm1.ObterDuracaoMP3_MS(const CaminhoArquivo: string): Int64;
var
  Reader: IMFSourceReader;
  PropVar: TPropVariant;
  Duracao100ns: Int64;
begin
  Result := 0;
  if Succeeded(MFCreateSourceReaderFromURL(PWideChar(CaminhoArquivo), nil, Reader)) then
  begin
    FillChar(PropVar, SizeOf(PropVar), 0);
    if Succeeded(Reader.GetPresentationAttribute(MF_SOURCE_READER_MEDIASOURCE, MF_PD_DURATION, PropVar)) then
    begin
      Duracao100ns := PropVar.uhVal.QuadPart;
      Result := Duracao100ns div 10000; // Converte 100ns para milissegundos
      PropVariantClear(PropVar);
    end;
  end;
end;

procedure TForm1.CarregarArquivosDiretorio(const Pasta: string);
var
  CurrentScanId: Integer;
begin
  if not TDirectory.Exists(Pasta) then
  begin
    ShowMessage('Diretório não encontrado: ' + Pasta);
    Exit;
  end;

  Inc(FScanRequestId);
  CurrentScanId := FScanRequestId;

  lbDisponiveis.Items.BeginUpdate;
  try
    lbDisponiveis.Items.Clear;
  finally
    lbDisponiveis.Items.EndUpdate;
  end;

  btnSelecionarPasta.Enabled := False;
  btnSelecionarPasta.Caption := 'A ler...';
  ProgressBar1.Style := pbstMarquee;
  MemoLog.Lines.Add('A varrer diretório em segundo plano: ' + Pasta + ' ...');

  TThread.CreateAnonymousThread(
    procedure
    var
      ListaTemp: TStringList;
      PastasQueue: TQueue<string>;
      PastaAtual: string;
      SR: TSearchRec;
      Ext: string;
      Total: Integer;
    begin
      ListaTemp := TStringList.Create;
      PastasQueue := TQueue<string>.Create;
      try
        PastasQueue.Enqueue(Pasta);

        while (PastasQueue.Count > 0) and (CurrentScanId = FScanRequestId) do
        begin
          PastaAtual := PastasQueue.Dequeue;

          if FindFirst(TPath.Combine(PastaAtual, '*.*'), faAnyFile, SR) = 0 then
          begin
            try
              repeat
                if (SR.Name = '.') or (SR.Name = '..') then
                  Continue;

                if (SR.Attr and faDirectory) <> 0 then
                begin
                  // Ignora pastas de sistema e lixeira para prevenir travamentos e erros de permissão
                  if not SameText(SR.Name, '$RECYCLE.BIN') and
                     not SameText(SR.Name, 'System Volume Information') and
                     not SameText(SR.Name, '$Recycle.Bin') then
                  begin
                    PastasQueue.Enqueue(TPath.Combine(PastaAtual, SR.Name));
                  end;
                end
                else
                begin
                  Ext := LowerCase(ExtractFileExt(SR.Name));
                  if (Ext = '.mp3') or (Ext = '.mp4') or (Ext = '.wav') or
                     (Ext = '.wma') or (Ext = '.ogg') or (Ext = '.m4a') or (Ext = '.aac') then
                  begin
                    ListaTemp.Add(TPath.Combine(PastaAtual, SR.Name));
                  end;
                end;
              until FindNext(SR) <> 0;
            finally
              FindClose(SR);
            end;
          end;
        end;

        if CurrentScanId = FScanRequestId then
          ListaTemp.Sort;

        Total := ListaTemp.Count;

        TThread.Queue(nil,
          procedure
          begin
            if CurrentScanId = FScanRequestId then
            begin
              lbDisponiveis.Items.BeginUpdate;
              try
                lbDisponiveis.Items.Assign(ListaTemp);
              finally
                lbDisponiveis.Items.EndUpdate;
              end;

              btnSelecionarPasta.Caption := 'Localizar...';
              btnSelecionarPasta.Enabled := True;
              ProgressBar1.Style := pbstNormal;
              ProgressBar1.Position := 0;

              MemoLog.Lines.Add(Format('Concluído! %d arquivos encontrados na pasta.', [Total]));
            end;
          end);
      finally
        PastasQueue.Free;
        ListaTemp.Free;
      end;
    end).Start;
end;

procedure TForm1.btnSelecionarPastaClick(Sender: TObject);
var
  Dlg: TFileOpenDialog;
begin
  Dlg := TFileOpenDialog.Create(nil);
  try
    Dlg.Options := [fdoPickFolders];
    if Dlg.Execute then
    begin
      edtPasta.Text := Dlg.FileName;
      CarregarArquivosDiretorio(Dlg.FileName);
    end;
  finally
    Dlg.Free;
  end;
end;

procedure TForm1.btnAdicionarClick(Sender: TObject);
var
  I: Integer;
begin
  lbPlaylist.Items.BeginUpdate;
  try
    for I := 0 to lbDisponiveis.Items.Count - 1 do
    begin
      if lbDisponiveis.Selected[I] then
        lbPlaylist.Items.Add(lbDisponiveis.Items[I]);
    end;
  finally
    lbPlaylist.Items.EndUpdate;
  end;
end;

procedure TForm1.btnAdicionarTodosClick(Sender: TObject);
var
  I: Integer;
begin
  lbPlaylist.Items.BeginUpdate;
  try
    for I := 0 to lbDisponiveis.Items.Count - 1 do
      lbPlaylist.Items.Add(lbDisponiveis.Items[I]);
  finally
    lbPlaylist.Items.EndUpdate;
  end;
end;

procedure TForm1.btnRemoverClick(Sender: TObject);
var
  I: Integer;
begin
  lbPlaylist.Items.BeginUpdate;
  try
    for I := lbPlaylist.Items.Count - 1 downto 0 do
    begin
      if lbPlaylist.Selected[I] then
        lbPlaylist.Items.Delete(I);
    end;
  finally
    lbPlaylist.Items.EndUpdate;
  end;
end;

procedure TForm1.btnRemoverTodosClick(Sender: TObject);
begin
  lbPlaylist.Items.Clear;
end;

procedure TForm1.btnSalvarPlaylistClick(Sender: TObject);
var
  SaveDlg: TSaveDialog;
  ListaSaida: TStringList;
  CaminhoArquivo: string;
  Idx: Integer;
  DuracaoMs: Int64;
  QtdTotal: Integer;
begin
  QtdTotal := lbPlaylist.Items.Count;
  if QtdTotal = 0 then
  begin
    ShowMessage('Adicione ao menos uma faixa na lista da direita antes de salvar.');
    Exit;
  end;

  SaveDlg := TSaveDialog.Create(nil);
  try
    SaveDlg.Filter := 'Playlist ZaraRadio (*.rot)|*.rot|Playlist ZaraRadio (*.lst)|*.lst|Todos os arquivos (*.*)|*.*';
    SaveDlg.DefaultExt := 'rot';
    SaveDlg.FileName := 'playlist.rot';

    if not SaveDlg.Execute then
      Exit;

    btnSalvarPlaylist.Enabled := False;
    ProgressBar1.Position := 0;
    ProgressBar1.Max := QtdTotal;
    MemoLog.Lines.Add('Calculando durações e gerando arquivo de rotação (.rot)...');
    Application.ProcessMessages;

    ListaSaida := TStringList.Create;
    try
      ListaSaida.Add('[playlist]');

      for Idx := 0 to QtdTotal - 1 do
      begin
        CaminhoArquivo := lbPlaylist.Items[Idx];
        DuracaoMs := ObterDuracaoMP3_MS(CaminhoArquivo);
        if DuracaoMs <= 0 then
          DuracaoMs := -2; // Padrão ZaraRadio para faixas sem duração pré-definida

        ListaSaida.Add(Format('file%d=%s', [Idx, CaminhoArquivo]));
        ListaSaida.Add(Format('length%d=%d', [Idx, DuracaoMs]));

        ProgressBar1.Position := Idx + 1;
        if (Idx mod 5 = 0) then
          Application.ProcessMessages;
      end;

      ListaSaida.Add(Format('numberofentries=%d', [QtdTotal]));
      ListaSaida.Add('nextindex=0');

      // Gravação em ANSI / Windows-1252 para compatibilidade com o ZaraRadio
      ListaSaida.SaveToFile(SaveDlg.FileName, TEncoding.ANSI);

      MemoLog.Lines.Add(Format('Sucesso! %d faixas salvas em: %s', [QtdTotal, SaveDlg.FileName]));
      ShowMessage('Playlist .rot do ZaraRadio salva com sucesso!');
    finally
      ListaSaida.Free;
      btnSalvarPlaylist.Enabled := True;
    end;
  finally
    SaveDlg.Free;
  end;
end;

// =========================================================================
// MÉTODOS DO PLAYER DE ÁUDIO (EM THREAD / ASSÍNCRONO)
// =========================================================================

procedure TForm1.PararAudio;
begin
  // Invalida requisições de áudio anteriores
  Inc(FPlayRequestId);
  FPlayerTocando := False;
  FPlayerPausado := False;
  lblPlayerStatus.Caption := 'Player: Parado';

  // Fecha o dispositivo em thread para não travar a interface
  TThread.CreateAnonymousThread(
    procedure
    begin
      mciSendString('stop mp3player', nil, 0, 0);
      mciSendString('close mp3player', nil, 0, 0);
    end).Start;
end;

procedure TForm1.TocarAudio(const Caminho: string);
var
  CurrentReq: Integer;
begin
  if not TFile.Exists(Caminho) then
  begin
    ShowMessage('Arquivo não encontrado: ' + Caminho);
    Exit;
  end;

  Inc(FPlayRequestId);
  CurrentReq := FPlayRequestId;

  FPlayerTocando := True;
  FPlayerPausado := False;
  lblPlayerStatus.Caption := 'Carregando: ' + ExtractFileName(Caminho);

  TThread.CreateAnonymousThread(
    procedure
    var
      Cmd: string;
      Ret: Cardinal;
      NomeArquivo: string;
    begin
      // Para e fecha qualquer reprodução anterior
      mciSendString('stop mp3player', nil, 0, 0);
      mciSendString('close mp3player', nil, 0, 0);

      // Se uma nova música já foi clicada enquanto esta fechava a anterior, cancela
      if CurrentReq <> FPlayRequestId then
        Exit;

      Cmd := Format('open "%s" type mpegvideo alias mp3player', [Caminho]);
      Ret := mciSendString(PChar(Cmd), nil, 0, 0);
      if Ret <> 0 then
      begin
        Cmd := Format('open "%s" alias mp3player', [Caminho]);
        Ret := mciSendString(PChar(Cmd), nil, 0, 0);
      end;

      if CurrentReq <> FPlayRequestId then
      begin
        mciSendString('close mp3player', nil, 0, 0);
        Exit;
      end;

      NomeArquivo := ExtractFileName(Caminho);

      if Ret = 0 then
      begin
        mciSendString('play mp3player', nil, 0, 0);
        TThread.Queue(nil,
          procedure
          begin
            if CurrentReq = FPlayRequestId then
            begin
              FPlayerTocando := True;
              FPlayerPausado := False;
              lblPlayerStatus.Caption := '▶ ' + NomeArquivo;
              MemoLog.Lines.Add('A reproduzir: ' + NomeArquivo);
            end;
          end);
      end
      else
      begin
        TThread.Queue(nil,
          procedure
          begin
            if CurrentReq = FPlayRequestId then
            begin
              FPlayerTocando := False;
              FPlayerPausado := False;
              lblPlayerStatus.Caption := 'Erro ao reproduzir';
              MemoLog.Lines.Add('Não foi possível tocar: ' + NomeArquivo);
            end;
          end);
      end;
    end).Start;
end;

procedure TForm1.btnPlayClick(Sender: TObject);
var
  Caminho: string;
begin
  if FPlayerPausado then
  begin
    FPlayerPausado := False;
    lblPlayerStatus.Caption := '▶ Em reprodução...';
    TThread.CreateAnonymousThread(
      procedure
      begin
        mciSendString('resume mp3player', nil, 0, 0);
      end).Start;
    Exit;
  end;

  Caminho := '';
  if lbDisponiveis.ItemIndex >= 0 then
    Caminho := lbDisponiveis.Items[lbDisponiveis.ItemIndex]
  else if lbPlaylist.ItemIndex >= 0 then
    Caminho := lbPlaylist.Items[lbPlaylist.ItemIndex]
  else if lbDisponiveis.Items.Count > 0 then
    Caminho := lbDisponiveis.Items[0];

  if Caminho <> '' then
    TocarAudio(Caminho);
end;

procedure TForm1.btnPauseClick(Sender: TObject);
begin
  if FPlayerTocando then
  begin
    if not FPlayerPausado then
    begin
      FPlayerPausado := True;
      lblPlayerStatus.Caption := '⏸ Pausado';
      TThread.CreateAnonymousThread(
        procedure
        begin
          mciSendString('pause mp3player', nil, 0, 0);
        end).Start;
    end
    else
    begin
      FPlayerPausado := False;
      lblPlayerStatus.Caption := '▶ Em reprodução...';
      TThread.CreateAnonymousThread(
        procedure
        begin
          mciSendString('resume mp3player', nil, 0, 0);
        end).Start;
    end;
  end;
end;

procedure TForm1.btnStopClick(Sender: TObject);
begin
  PararAudio;
end;

procedure TForm1.lbDisponiveisDblClick(Sender: TObject);
begin
  if lbDisponiveis.ItemIndex >= 0 then
    TocarAudio(lbDisponiveis.Items[lbDisponiveis.ItemIndex]);
end;

procedure TForm1.lbPlaylistDblClick(Sender: TObject);
begin
  if lbPlaylist.ItemIndex >= 0 then
    TocarAudio(lbPlaylist.Items[lbPlaylist.ItemIndex]);
end;

// =========================================================================
// MÉTODOS DA SEÇÃO 2: MONTAGEM E PREVIEW DE PLAYLIST MASTER .LST
// =========================================================================

procedure TForm1.AtualizarPreviewLst;
var
  Idx, QtdTotal: Integer;
  Item: string;
begin
  MemoPreviewLst.Lines.BeginUpdate;
  try
    MemoPreviewLst.Lines.Clear;
    QtdTotal := lbPlaylistLst.Items.Count;
    if QtdTotal = 0 then
      Exit;

    // Linha 1: quantidade total
    MemoPreviewLst.Lines.Add(IntToStr(QtdTotal));

    // Linhas seguintes: -1 [TAB] caminho_ou_comando
    for Idx := 0 to QtdTotal - 1 do
    begin
      Item := Trim(lbPlaylistLst.Items[Idx]);
      MemoPreviewLst.Lines.Add(Format('-1'#9'%s', [Item]));
    end;
  finally
    MemoPreviewLst.Lines.EndUpdate;
  end;
end;

procedure TForm1.btnBuscarRotClick(Sender: TObject);
var
  OpenDlg: TOpenDialog;
  I: Integer;
begin
  OpenDlg := TOpenDialog.Create(nil);
  try
    OpenDlg.Filter := 'Arquivos de Rotação ZaraRadio (*.rot)|*.rot|Todos os arquivos (*.*)|*.*';
    OpenDlg.DefaultExt := 'rot';
    OpenDlg.Options := [ofAllowMultiSelect, ofFileMustExist];
    if OpenDlg.Execute then
    begin
      lbPlaylistLst.Items.BeginUpdate;
      try
        for I := 0 to OpenDlg.Files.Count - 1 do
          lbPlaylistLst.Items.Add(OpenDlg.Files[I]);
        MemoLog.Lines.Add(Format('%d arquivo(s) .rot adicionado(s) à lista.', [OpenDlg.Files.Count]));
      finally
        lbPlaylistLst.Items.EndUpdate;
        AtualizarPreviewLst;
      end;
    end;
  finally
    OpenDlg.Free;
  end;
end;

procedure TForm1.btnAdicionarHoraClick(Sender: TObject);
begin
  lbPlaylistLst.Items.Add('.time');
  AtualizarPreviewLst;
  MemoLog.Lines.Add('Comando de hora (.time) inserido na sequência.');
end;

procedure TForm1.btnLimparLstClick(Sender: TObject);
begin
  lbPlaylistLst.Items.Clear;
  AtualizarPreviewLst;
  MemoLog.Lines.Add('Lista master limpa.');
end;

procedure TForm1.btnSubirLstClick(Sender: TObject);
var
  Idx: Integer;
begin
  Idx := lbPlaylistLst.ItemIndex;
  if Idx > 0 then
  begin
    lbPlaylistLst.Items.Exchange(Idx, Idx - 1);
    lbPlaylistLst.ItemIndex := Idx - 1;
    AtualizarPreviewLst;
  end;
end;

procedure TForm1.btnDescerLstClick(Sender: TObject);
var
  Idx: Integer;
begin
  Idx := lbPlaylistLst.ItemIndex;
  if (Idx >= 0) and (Idx < lbPlaylistLst.Items.Count - 1) then
  begin
    lbPlaylistLst.Items.Exchange(Idx, Idx + 1);
    lbPlaylistLst.ItemIndex := Idx + 1;
    AtualizarPreviewLst;
  end;
end;

procedure TForm1.btnRemoverItemLstClick(Sender: TObject);
var
  I: Integer;
begin
  lbPlaylistLst.Items.BeginUpdate;
  try
    for I := lbPlaylistLst.Items.Count - 1 downto 0 do
    begin
      if lbPlaylistLst.Selected[I] then
        lbPlaylistLst.Items.Delete(I);
    end;
  finally
    lbPlaylistLst.Items.EndUpdate;
    AtualizarPreviewLst;
  end;
end;

procedure TForm1.btnSalvarLstClick(Sender: TObject);
var
  SaveDlg: TSaveDialog;
  ListaSaida: TStringList;
  Idx, QtdTotal: Integer;
  Item: string;
begin
  QtdTotal := lbPlaylistLst.Items.Count;
  if QtdTotal = 0 then
  begin
    ShowMessage('Adicione ao menos um item (.rot ou .time) na lista master antes de salvar.');
    Exit;
  end;

  SaveDlg := TSaveDialog.Create(nil);
  try
    SaveDlg.Filter := 'Playlist ZaraRadio (*.lst)|*.lst|Todos os arquivos (*.*)|*.*';
    SaveDlg.DefaultExt := 'lst';
    SaveDlg.FileName := 'playlist.lst';

    if not SaveDlg.Execute then
      Exit;

    ListaSaida := TStringList.Create;
    try
      // Linha 1: quantidade total de itens adicionados
      ListaSaida.Add(IntToStr(QtdTotal));

      // Linhas seguintes: -1 [TAB] caminho_ou_comando
      for Idx := 0 to QtdTotal - 1 do
      begin
        Item := Trim(lbPlaylistLst.Items[Idx]);
        ListaSaida.Add(Format('-1'#9'%s', [Item]));
      end;

      // Gravação em formato ANSI para compatibilidade com o ZaraRadio
      ListaSaida.SaveToFile(SaveDlg.FileName, TEncoding.ANSI);

      // Atualiza o preview lendo diretamente o arquivo gerado no disco
      MemoPreviewLst.Lines.LoadFromFile(SaveDlg.FileName, TEncoding.ANSI);

      MemoLog.Lines.Add(Format('Sucesso! Playlist master .lst salva com %d itens em: %s', [QtdTotal, SaveDlg.FileName]));
      ShowMessage('Playlist Master (.lst) gerada com sucesso para o ZaraRadio!');
    finally
      ListaSaida.Free;
    end;
  finally
    SaveDlg.Free;
  end;
end;

initialization
  RegisterClasses([TLabel, TListBox, TButton, TEdit, TProgressBar, TMemo]);

end.
