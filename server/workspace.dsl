workspace "Adi3000 system" {

    model {
        
        // Personnes
        storageUser = person "Need file storage"
        homeUser = person "Need home automation"
        streamUser = person "Need media streaming"
        blogUser = person "Need to write an article"
        cerbinouUser = person "Need to ask a question"
        gamerUser = person "Need to Game"
        computerUser = person "Need to use Internet"
        downloaderUser = person "Need a new download"
        mailUser = person "Need some mails"

        cloudInstance = softwareSystem "Google Cloud" "Google Cloud Plateform" {
            cloudRun = container "GCP Cloud Run" "Serverless docker instances" {
                gcpAuthentik = component "Authentik"
                gcpNextCloud = component "Nextcloud"
                gcpWordPress = component "Wordpress"
                gcpPlex = component "Plex Server"
            }
            runPod = container "RunPod" "IA dedicated instances" {
                cerbinouASR = component "ASR engine"
                cerbinouTranscript = component "Transcript engine"
                cerbinouLLM = component "LLM engine"
                cerbinouSpeech = component "Audio speech engine"
            }
            mailbox = container "Mailboxes" {
                freeMails = component "Mail from free.fr"
            }
        }
        
        
        aiven = softwareSystem "Aiven Data storage" {
            postgresql = container "PostgreSQL"  {
                pgAuthentik = component "Postgresql Authentik"
                pgNextcloud = component "Postgresql Nextcloud"
            }
            redis = container "Redis" {
                redisAuthentik = component "Redis Authentik"
            }
            mySql = container "Cloud Run"  {
                wpBlogs = component "MySQL Wordpress"
            }
        }

        vps = softwareSystem "VPS" {
            homeAutomationServices = container "Home Automation" {
                mqtt = component "Zigbee MQTT Server"
                rednode = component "Rednode for home"
                homeAssistant = component "Home assistant for Maman-home"
            }
            blocky = container "Blocky DNS" {
                parentalControl = component "Parental DNS filtering"
                adRemover = component "Ads DNS filtering"
            }
            traefik = container "Traefik" {
                authentikDomain = component "login.adi3000.com"
                fafnirDomain = component "fafnir.adi3000.com"
                homeDomain = component "adi-home.adi3000.com"
                plexDomain = component "plex.adi3000.com"
                blogDomains = component "blogs domains"
            }
            torrent = container "Torrent downloader" {
                rutorrent = component "Rutorrent"
                rtorrent = component "RTorrent"
            }
            fileAnalyzer = container "Classifier for files Storage" {
                photoTagger = component "Auto tag photo"
            }
            metrics = container "Metrics gatherer" {
                telegramNotifier = component "Alerting via Telegram"
            }
            mailAnalayer = container "Tool to analyze mails" {
                spamassassin = component "Spamassassin"
            }
        }

        home = softwareSystem "Home component" {
            computer = container "Computer" {
                moonlight = component "Moonlight"    
            }
            router = container "Router" {
                ps4Port = component "Port PS4"
                moonLightPort = component "Port Moonlight"
            }
            ps4 = container "PS4" {
                remotePlay = component "Remote play"
            }
            zigbeeMesh = container "Zigbee Mesh" {
                homeAutomationComponent = component "Components Zigbee"
            }
            pizigbee = container "PiZigbee" {
                homeZ2MQTT = component "Zigbee2MQTT"
                remoteDomoPi = component "Remote Domo Pi"
                cerbinou = component "Cerbinou"
                ps4Trigger = component "PS4 controller"
            }
            raspberry = container "Raspian" {
                fileStorage = component "File Storage"
                streamStorage = component "Movie/Serie Storage"
            }
        }
        
        storageUser -> fafnirDomain "Call for Nextcloud"
        fafnirDomain -> gcpAuthentik "Ensure authentication"
        gcpAuthentik -> pgAuthentik "Preserve users info"
        fafnirDomain -> gcpNextCloud "Trigger Nextcloud instance"
        gcpNextCloud -> pgNextcloud "Read data"
        gcpNextCloud -> fileStorage "Fetch files"
        photoTagger -> fileStorage "Autotag Photo"
        photoTagger -> pgNextcloud "Enhence photo metadata"
        
        homeUser -> homeDomain "Call for HomeDomain"
        homeDomain -> gcpAuthentik "Ensure authentication"
        homeDomain -> rednode "Controle house"
        rednode -> telegramNotifier "Send alerts"
        rednode -> homeZ2MQTT "Receive signals"
        
        streamUser -> plexDomain "Stream a movie"
        plexDomain -> gcpAuthentik "Ensure authentication"
        plexDomain -> gcpPlex "Stream video"
        gcpPlex -> streamStorage "Fetch film to stream"
        
        blogUser -> blogDomains "Maintain blogs"
        blogDomains -> gcpAuthentik "Ensure authentication"
        blogDomains -> gcpWordPress "Expose blog"
        gcpWordPress -> wpBlogs "Store blog data"
        
        cerbinouUser -> cerbinou "Ask a question"
        cerbinou -> cerbinouASR "Listen question"
        cerbinou -> cerbinouTranscript "Understand question"
        cerbinou -> cerbinouSpeech "Understand question"
        cerbinou -> cerbinouLLM "Formulate answer"
        cerbinou -> telegramNotifier "Send answer and question"
        cerbinou -> cerbinouSpeech "Answer question"
        
        gamerUser -> homeAssistant "Wakeup computer"
        homeAssistant -> ps4Trigger "Wakeup PS4"
        gamerUser -> moonlight "Use computer"
        gamerUser -> remotePlay "Use PS4"
        
        computerUser -> parentalControl "Avoid unwanted site"
        computerUser -> adRemover "Remove some ads"
        
        downloaderUser -> fafnirDomain "Call for downloader"
        fafnirDomain -> rutorrent "Find some stuff to download"
        rutorrent -> rtorrent "Control downloader"
        rtorrent -> streamStorage "Save movies"
        rtorrent -> fileStorage "Save files"
        
        mailUser -> freeMails "Receive mails"
        freeMails -> spamassassin "Filter SPAMs"
        
    }
    views {
        styles {        
            element "Component" {
                background #96c2af
                color #ffffff
            }
            element "Container" {
                background #6894b9
                color #ffffff
            }
            element "Person" {
                shape Person
                background #08427b
                color #ffffff
            }
        }
    }

}
