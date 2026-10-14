object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Gerador de Playlists e Rota'#231#245'es - ZaraRadio'
  ClientHeight = 540
  ClientWidth = 1420
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 15
  object lblPasta: TLabel
    Left = 20
    Top = 15
    Width = 197
    Height = 15
    Caption = 'Diret'#243'rio com m'#250'sicas (MP3, MP4...):'
  end
  object lblDisponiveis: TLabel
    Left = 20
    Top = 70
    Width = 127
    Height = 15
    Caption = 'M'#250'sicas do Diret'#243'rio:'
  end
  object lblPlaylist: TLabel
    Left = 385
    Top = 70
    Width = 143
    Height = 15
    Caption = 'M'#250'sicas da Playlist (.rot):'
  end
  object lblPlayerStatus: TLabel
    Left = 222
    Top = 333
    Width = 105
    Height = 15
    Caption = 'Player: Parado'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Segoe UI'
    Font.Style = [fsItalic]
    ParentFont = False
  end
  object lblPlaylistLst: TLabel
    Left = 710
    Top = 15
    Width = 169
    Height = 15
    Caption = 'Playlist Master ZaraRadio (.lst):'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object lblPreviewLst: TLabel
    Left = 1060
    Top = 15
    Width = 146
    Height = 15
    Caption = 'Preview do Arquivo .LST:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object edtPasta: TEdit
    Left = 20
    Top = 35
    Width = 560
    Height = 23
    TabOrder = 0
  end
  object btnSelecionarPasta: TButton
    Left = 590
    Top = 34
    Width = 95
    Height = 25
    Caption = 'Localizar...'
    TabOrder = 1
    OnClick = btnSelecionarPastaClick
  end
  object lbDisponiveis: TListBox
    Left = 20
    Top = 90
    Width = 310
    Height = 230
    MultiSelect = True
    TabOrder = 2
    OnDblClick = lbDisponiveisDblClick
  end
  object btnPlay: TButton
    Left = 20
    Top = 328
    Width = 62
    Height = 28
    Caption = 'Play'
    TabOrder = 3
    OnClick = btnPlayClick
  end
  object btnPause: TButton
    Left = 86
    Top = 328
    Width = 62
    Height = 28
    Caption = 'Pausar'
    TabOrder = 4
    OnClick = btnPauseClick
  end
  object btnStop: TButton
    Left = 152
    Top = 328
    Width = 62
    Height = 28
    Caption = 'Parar'
    TabOrder = 5
    OnClick = btnStopClick
  end
  object btnAdicionar: TButton
    Left = 338
    Top = 130
    Width = 40
    Height = 30
    Caption = '>'
    TabOrder = 6
    OnClick = btnAdicionarClick
  end
  object btnAdicionarTodos: TButton
    Left = 338
    Top = 170
    Width = 40
    Height = 30
    Caption = '>>'
    TabOrder = 7
    OnClick = btnAdicionarTodosClick
  end
  object btnRemover: TButton
    Left = 338
    Top = 220
    Width = 40
    Height = 30
    Caption = '<'
    TabOrder = 8
    OnClick = btnRemoverClick
  end
  object btnRemoverTodos: TButton
    Left = 338
    Top = 260
    Width = 40
    Height = 30
    Caption = '<<'
    TabOrder = 9
    OnClick = btnRemoverTodosClick
  end
  object lbPlaylist: TListBox
    Left = 385
    Top = 90
    Width = 300
    Height = 270
    MultiSelect = True
    TabOrder = 10
    OnDblClick = lbPlaylistDblClick
  end
  object btnSalvarPlaylist: TButton
    Left = 20
    Top = 370
    Width = 665
    Height = 35
    Caption = 'Salvar Playlist ZaraRadio (.rot)...'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 11
    OnClick = btnSalvarPlaylistClick
  end
  object btnBuscarRot: TButton
    Left = 710
    Top = 35
    Width = 140
    Height = 25
    Caption = 'Buscar .ROT no HD...'
    TabOrder = 12
    OnClick = btnBuscarRotClick
  end
  object btnAdicionarHora: TButton
    Left = 858
    Top = 35
    Width = 130
    Height = 25
    Caption = '+ Hora Certa (.time)'
    TabOrder = 13
    OnClick = btnAdicionarHoraClick
  end
  object btnLimparLst: TButton
    Left = 995
    Top = 35
    Width = 55
    Height = 25
    Caption = 'Limpar'
    TabOrder = 14
    OnClick = btnLimparLstClick
  end
  object lbPlaylistLst: TListBox
    Left = 710
    Top = 70
    Width = 275
    Height = 290
    MultiSelect = True
    TabOrder = 15
  end
  object btnSubirLst: TButton
    Left = 992
    Top = 115
    Width = 60
    Height = 32
    Caption = 'Subir'
    TabOrder = 16
    OnClick = btnSubirLstClick
  end
  object btnDescerLst: TButton
    Left = 992
    Top = 155
    Width = 60
    Height = 32
    Caption = 'Descer'
    TabOrder = 17
    OnClick = btnDescerLstClick
  end
  object btnRemoverItemLst: TButton
    Left = 992
    Top = 205
    Width = 60
    Height = 32
    Caption = 'Remover'
    TabOrder = 18
    OnClick = btnRemoverItemLstClick
  end
  object MemoPreviewLst: TMemo
    Left = 1060
    Top = 70
    Width = 345
    Height = 290
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Consolas'
    Font.Style = []
    ParentFont = False
    ReadOnly = True
    ScrollBars = ssBoth
    TabOrder = 19
    WordWrap = False
  end
  object btnSalvarLst: TButton
    Left = 710
    Top = 370
    Width = 695
    Height = 35
    Caption = 'Salvar Playlist Master (.lst)...'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 20
    OnClick = btnSalvarLstClick
  end
  object ProgressBar1: TProgressBar
    Left = 20
    Top = 415
    Width = 1385
    Height = 17
    TabOrder = 21
  end
  object MemoLog: TMemo
    Left = 20
    Top = 440
    Width = 1385
    Height = 85
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 22
  end
end
