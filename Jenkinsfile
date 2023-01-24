pipeline{
    agent{

    }
    tools{
        maven 'MAVEN_3.6.3'
        jdk 'JDK-8'
    }
    environment{
        registry='lite2k/vproapp-cicd'
        dockerCredentials='dockerCreds'
    }
    stages{
        stage('MVN: Build app'){
            steps{
                sh 'mvn clean install -DskipTests'
            }
            post{
                success{
                    echo 'Archiving artifact....'
                    archiveArtifacts artifacts: '**/target/*.war'
                }
            }
        }
        stage('MVN: Test app'){
            steps{
                sh 'mvn test'  
            }
        }
        stage('MVN: CheckStyle analysis')
        {
            steps{
                sh 'mvn checkstyle:checkstyle'
            }
        }
        stage('SonarQube: CheckStyle'){
            environment
            {
                scannerHome = 'sonar_scanner'
            }
            tools{
                jdk 'JDK-11'
            }
            steps{
                withSonarQubeEnv('sonar'){
                    sh '''${scannerHome}/bin/sonar-scanner -Dsonar.projectKey=vprofile \
                   -Dsonar.projectName=vprofile \
                   -Dsonar.projectVersion=1.0 \
                   -Dsonar.sources=src/ \
                   -Dsonar.java.binaries=target/test-classes/com/visualpathit/account/controllerTest/ \
                   -Dsonar.junit.reportsPath=target/surefire-reports/ \
                   -Dsonar.jacoco.reportsPath=target/jacoco.exec \
                   -Dsonar.java.checkstyle.reportPaths=target/checkstyle-result.xml'''
                }
                timeout(time:5,units:'MINUTES'){
                    waitForQualityGate abortPipeline: true
                }
            }
        }
        stage('DOCKER: Build Image'){
            steps{
                script{
                    dockerImage = docker.build registry + ":V$BUILD_NUMBER"
                }
            }
        }
        satge('DOCKER: Upload Image')
        {
            steps{
                script{
                    docker.WithRegistry('',dockerCreds){
                        dockerImage.push("V$BUILD_NUMBER")
                        dockerImage.push('latest')
                    }
                }
            }
        }
        stage('DOCKER: Remove unused containers')
        { 
            steps{
                sh "docker rmi $registry:V$BUILD_NUMBER"
            }
        }
        stage('HELM: Deploy Kubernetes cluster'){
            sh 'helm upgrade --install --force vprofile-stack helm/vpro-charts --set appImage=$($registry):V$(BUILD_NUMBER)'
        }
    }
    
}
