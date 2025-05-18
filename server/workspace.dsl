workspace "Adi3000 system" {

    model {
        
        // Personnes
        storageUser = person "Need file storage"
        homeUser = person "Need home automation"
        streamUser = person "Need media streaming"
        blogUser = person "Need to write an article"
        cerbinouUser = person "Need to ask a question"
        gamerUser = person "Need to Game"

        google = softwareSystem "Google Cloud" "Google Cloud Plateform" {
            cloudRun = container "Cloud Run" "Serverless docker instances" {
                gcpAuthentik = component "Authentik"
                gcpNextCloud = component "Nextcloud"
            }
        }
        
        aiven = softwareSystem "Datalake" "Stockage des données pour analyse" {
            postgresql = container "PostgreSQL"  {
                pgAuthentik = component "Postgresql Authentik"
                pgNextcloud = component "Postgresql Nextcloud"
            }
            redis = container "Redis" {
                redisAuthentik = component "Redis Authentik"
            }
            mySql = container "Cloud Run"  {
                wpPriseDeTete = component "MySQL Prise de tete"
                wpZapette = component "MySQL LaZapette"
            }
        }

        vps = softwareSystem "VPS" {
            mqtt = container "MQTT server" {
                homeTopic = component "Home Zigbee MQTT"
            }
            blocky = container "Blocky DNS" {
                parentalControl = component "Parental DNS filtering"
                adRemover = component "Ads DNS filtering"
            }
            traefik = container "Traefik" {
                authentikDomain = component "login.adi3000.com"
                fafnirDomain = component "fafnir.adi3000.com"
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
            }
            raspberry = container "Raspian" {
                fileStorage = component "File Storage"
            }
        }
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
