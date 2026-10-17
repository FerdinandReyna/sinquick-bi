// Pipeline CI/CD de SIN-Quick
// Etapas: Checkout → Build → Test → Deploy Staging
// Agente: Windows con SQL Server 2022 Developer (motor + SSIS), .NET SDK, SqlPackage,
// sqlcmd, Python 3 y las herramientas SSIS DevOps. Ver docs/ci/instalar-jenkins-windows.md

pipeline {
    agent { label 'windows-sql' }

    options {
        timestamps()
        timeout(time: 60, unit: 'MINUTES')
        buildDiscarder(logRotator(numToKeepStr: '20'))
        skipDefaultCheckout(true)
    }

    parameters {
        booleanParam(name: 'PUBLICAR_POWERBI', defaultValue: false,
                     description: 'Publicar el informe en el área de trabajo de staging de Power BI (requiere Power BI Pro)')
    }

    environment {
        SQL_SERVER  = 'localhost'
        BD_CI       = 'SINQuick_CI'
        BD_STAGING  = 'SINQuick_Staging'
        ETL_CARPETA = 'C:\\SINQuick\\CI\\entrada'
        SSIS_DEVOPS = 'C:\\Herramientas\\SSISDevOps'
    }

    stages {

        stage('Checkout') {
            steps {
                cleanWs()
                checkout scm
                bat 'git log -1 --pretty=format:"Commit %%h - %%an - %%s"'
            }
        }

        stage('Build') {
            parallel {
                stage('Base de datos (DACPAC)') {
                    steps { powershell '.\\ci\\build-db.ps1' }
                }
                stage('ETL (SSIS .ispac)') {
                    steps { powershell '.\\ci\\build-etl.ps1' }
                }
            }
            post {
                success { archiveArtifacts artifacts: 'artefactos/**', fingerprint: true }
            }
        }

        stage('Test') {
            stages {
                stage('Desplegar base de pruebas') {
                    steps { powershell '.\\ci\\publicar-db.ps1 -Base $env:BD_CI -Recrear' }
                }
                stage('Unitarias (tSQLt)') {
                    steps { powershell '.\\ci\\pruebas-tsqlt.ps1 -Base $env:BD_CI' }
                }
                stage('Integración, sistema, aceptación, seguridad y rendimiento (pytest)') {
                    steps { powershell '.\\ci\\pruebas-pytest.ps1 -Base $env:BD_CI' }
                }
            }
            post {
                always {
                    junit allowEmptyResults: true, testResults: 'reportes/tsqlt.xml, reportes/pytest.xml'
                    publishHTML(target: [reportName: 'Reporte de pruebas (pytest)', reportDir: 'reportes',
                                         reportFiles: 'pytest.html', keepAll: true, alwaysLinkToLastBuild: true,
                                         allowMissing: true])
                }
            }
        }

        stage('Deploy Staging') {
            // Solo las ramas integradas llegan a staging; las ramas feature/* se prueban pero no se despliegan
            when { expression { (env.BRANCH_NAME ?: env.GIT_BRANCH ?: '') ==~ /(origin\/)?(main|develop)/ } }
            steps {
                powershell '.\\ci\\publicar-db.ps1 -Base $env:BD_STAGING'
                powershell '.\\ci\\desplegar-etl.ps1 -Carpeta Staging -Base $env:BD_STAGING'
                powershell '.\\ci\\pruebas-pytest.ps1 -Base $env:BD_STAGING -Humo'
                script {
                    if (params.PUBLICAR_POWERBI) {
                        withCredentials([
                            string(credentialsId: 'pbi-cliente',   variable: 'PBI_CLIENTE'),
                            string(credentialsId: 'pbi-secreto',   variable: 'PBI_SECRETO'),
                            string(credentialsId: 'pbi-inquilino', variable: 'PBI_INQUILINO'),
                            string(credentialsId: 'pbi-area-staging', variable: 'PBI_AREA_STAGING')
                        ]) {
                            powershell '.\\ci\\publicar-powerbi.ps1'
                        }
                    }
                }
            }
            post {
                always {
                    junit allowEmptyResults: true, testResults: 'reportes/pytest-staging.xml'
                }
            }
        }
    }

    post {
        success { echo 'Pipeline aprobado: la versión quedó desplegada en staging.' }
        failure { echo 'Pipeline fallido: revisar la etapa en rojo y el reporte de pruebas.' }
    }
}
