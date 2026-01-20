# 🧩 NeoVcore V6 — Windows Feature Manager  
### Desenvolvido por **Bruno Kupper**  
🔗 Repositório oficial: https://github.com/brunokupper/neovcore  


O **Neo Vcore V6** é uma ferramenta avançada em PowerShell para gerenciamento de recursos ocultos do Windows, utilizando o mecanismo do **ViVeTool**.  
Ele oferece uma interface moderna, menus organizados, ativação individual ou por categoria e integração modular.


> ⚠️ Esta é a versão **6.x**, focada em estabilidade.  
> A versão **7.x** trará: presets, categorias inteligentes, IDs confirmados por build e biblioteca oficial de recursos.


---


## 🚀 Recursos principais


- Interface moderna em PowerShell  
- Ativação e desativação de recursos individuais  
- Ativação por categoria  
- Suporte a IDs personalizados  
- Sistema modular  
- Atualização automática via GitHub  
- Preparado para expansão na versão 7  


---


## 📦 Instalação (PowerShell)


Execute:


```powershell
irm https://raw.githubusercontent.com/brunokupper/neovcore/main/install.ps1 | iex
```


🔧 Como usar
Após instalar:


 ```PowerShell
neovcore
 ```


📁 Estrutura do projeto


 ```Text
/NeoVcore
  NeoVcore.ps1
  install.ps1
  update.ps1
  README.md

  /data
      features.json
      logs.txt
      presets.json
      Settings.json
      version.txt

  /modules
      AdvancedTools.psm1
      CategoryLoader.psm1
      CategoryMenu.psm1
      DeveloperMenu.psm1
      FeatureControl.psm1
      Header.psm1
      Logger.psm1
      MainMenu.psm1
      Maintenance.psm1
      NeoVcoreUpdater.psm1
      Optimization.psm1
      PresetMenu.psm1
      Presets.psm1
      Rollback.psm1
      Scanner.psm1
      SearchID.psm1
      Settings.psm1
      SettingsManager.psm1
      Submenus.psm1
      SystemInfo.psm1
      Updater.psm1
      Validator.psm1
      VersionManager.psm1
      Vivetool.psm1
      VivetoolMenu.psm1

  /vivetool
      ViVeTool.exe
      Albacore.ViVe.dll
      FeatureDictionary.pfs
      Newtonsoft.Json.dll
 ```


🔄 Atualização


 ```PoweShell
neovcore --update
 ```


ou


 ```PowerShell
irm https://raw.githubusercontent.com/brunokupper/neovcore/main/update.ps1 | iex
 ```


🛠️ Compatibilidade
- Windows 11 (todas as versões)
- PowerShell 5.1+
- Permissões administrativas
- ViVeTool integrado


🧭 Roadmap
Versão 6.x
- Interface padronizada
- Correções de módulos
- Base sólida para expansão
Versão 7.x
- IDs reais por build
- Biblioteca oficial
- Presets inteligentes
- Atualização incremental
- Modo seguro para recursos experimentais


📜 Licença
Distribuído sob a licença MIT.


✨ Autor
Desenvolvido por Bruno Kupper
