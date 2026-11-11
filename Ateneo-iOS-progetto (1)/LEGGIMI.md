# Ateneo per iPhone — progetto da compilare

Questo pacchetto NON è ancora un IPA. Contiene il progetto iOS e una procedura per generarlo su un Mac cloud di GitHub Actions. Non è stato compilato o provato su iPhone in questo ambiente Linux.

## Da Windows

1. Accedi a GitHub o crea un account su https://github.com.
2. Crea un nuovo repository PRIVATO chiamato `ateneo-ios`, inizializzandolo con un README. Le compilazioni usano la quota GitHub Actions del tuo piano: verifica i minuti disponibili e non abilitare spese aggiuntive se non desideri addebiti.
3. Estrai questo ZIP. Nel repository scegli **Add file → Upload files** e carica la cartella `App` e il file `project.yml`. Mantieni `App/Web` con tutti i suoi file. Conferma con **Commit changes**.
4. Il workflow è in una cartella nascosta: per aggiungerlo dal sito GitHub scegli **Add file → Create new file**. Nel nome scrivi esattamente `.github/workflows/build-ios.yml`. Apri il file omonimo dello ZIP con Blocco note e incollane tutto il contenuto. Conferma con **Commit changes**.
5. Apri la scheda **Actions**, abilita le Actions se richiesto, seleziona **Crea IPA Ateneo**, poi **Run workflow**. La compilazione richiede alcuni minuti.
6. Quando il processo è verde, aprilo e scarica l'artefatto **Ateneo-IPA-per-Sideloadly** in fondo alla pagina. Estrai lo ZIP scaricato: dentro trovi `Ateneo-unsigned.ipa`.
7. Apri Sideloadly su Windows, collega e autorizza l'iPhone, trascina `Ateneo-unsigned.ipa`, inserisci il tuo Apple ID direttamente in Sideloadly e avvia l'installazione. Non inserire password o codici Apple in chat o nei file GitHub.
8. Se iOS lo richiede, autorizza il profilo in **Impostazioni → Generali → VPN e gestione dispositivo** e abilita **Modalità sviluppatore** in **Privacy e sicurezza** seguendo le indicazioni del telefono.

Sideloadly firma l'IPA durante l'installazione. Con Apple ID gratuito la firma dura normalmente 7 giorni; rinnova mantenendo lo stesso identificativo app e Apple ID. Non eliminare l'app per rinnovarla: potresti perdere i dati locali. Esporta periodicamente un backup e salva gli audio separatamente.

## Cosa include

L'app contiene le pagine di Ateneo e le apre in WKWebView: non richiede il sito privato o un login ChatGPT. Presenze, note e registrazioni rimangono nel contenitore locale dell'app. Gli elementi principali funzionano senza rete; il font online è facoltativo. Il backup e il download degli audio usano il foglio di condivisione di iOS (Salva su File). Puoi importare un backup JSON dalla pagina, mentre gli audio vanno caricati separatamente.

I dati presenti in Safari o sul computer non vengono importati automaticamente. Gli avvisi per esami sono mostrati nell'app; non sono notifiche push.

## Limiti di verifica

La compilazione Xcode, la scelta dei file audio, la persistenza su iOS e il foglio di condivisione devono essere verificati su Mac/iPhone. Se Actions fallisce, apri il passaggio rosso e conserva il messaggio di errore per la correzione. Un esito verde conferma la compilazione, non il collaudo su dispositivo.
