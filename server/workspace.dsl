workspace "Système de Gestion de Conférence" "Système de gestion des inscriptions et données de conférence" {

    model {
        
        // Personnes
        storageUser = person "Need file storage"
        homeUser = person "Need home automation"
        streamUser = person "Need media streaming"

        // Systèmes externes
        google = softwareSystem "Google Cloud" "Google Cloud Plateform" {
            cloudRun = container "Cloud Run" "Serverless docker instances" {
                gcpAuthentik = component "Authentik"
                gcpNextCloud = component "Nextcloud"
            }
        }
        
                // Systèmes externes
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

    }
    views {
        styles {
            element systemeGestionConference {
                background #1168bd
                color #ffffff
            }
        
            element datalake {
                background #85bb43
                color #ffffff
            }
        
            element siteWeb {
                background #ff9900
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
