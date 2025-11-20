pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub')
        DOCKERHUB_REPO = "sjm31566/djangoapp"
    }

    triggers {
        pollSCM('H/1 * * * *')   // GitHub webhook 사용 시 제거 가능
    }

    stages {

        stage('Clone Repository') {
            steps {
                echo "Git Repo 최신 내용 가져오기"
                checkout scm
            }
        }

        stage('Set Version') {
            steps {
                script {
                    // Jenkins 빌드번호 기반 버전
                    VERSION = "v${BUILD_NUMBER}"
                    IMAGE_TAG = "${DOCKERHUB_REPO}:${VERSION}"

                    echo "새 Docker 이미지 버전: ${IMAGE_TAG}"
                }
            }
        }

        stage('Docker Build') {
            steps {
                script {
                    sh """
                    docker build -t ${IMAGE_TAG} .
                    """
                }
            }
        }

        stage('Docker Login') {
            steps {
                script {
                    sh """
                    echo "${DOCKERHUB_CREDENTIALS_PSW}" | docker login -u "${DOCKERHUB_CREDENTIALS_USR}" --password-stdin
                    """
                }
            }
        }

        stage('Docker Push') {
            steps {
                script {
                    sh """
                    docker push ${IMAGE_TAG}
                    """
                }
            }
        }
        stage('Update K8s Manifest Repo') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'github-token', usernameVariable: 'GIT_USER', passwordVariable: 'GIT_TOKEN')]){
                      sh """
                      rm -rf kube_pjt_yaml1 || true
                      git clone -b master https://github.com/sjm31566/kube_pjt_yaml1.git
                      cd kube_pjt_yaml1/app

                      # 이미지 태그 자동 교체 (django-deployment.yaml)
                      sed -i 's#image: sjm31566/djangoapp:.*#image: ${IMAGE_TAG}#g' django-deployment.yaml

                      git config user.email "sjm31566@gmail.com"
                      git config user.name "sjm31566"

                      git commit -am "update image tag to ${IMAGE_TAG}"
                      git push https://${GIT_USER}:${GIT_TOKEN}@github.com/sjm31566/kube_pjt_yaml1.git
                      """
		    }
                }
            }
        }
    }


    post {
        success {
            echo "성공적으로 Docker Hub에 push 완료!"
        }
        failure {
            echo "빌드 실패! 로그를 확인하세요."
        }
    }
}
   
