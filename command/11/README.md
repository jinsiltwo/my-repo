# 11장

## 프라이빗 리포지터리 작성

```shell
gh repo create gh-oidc --private --clone --add-readme
cd gh-oidc
```


## AWS의 OpenID Connect 사용 기준の利用準備

이후는 AWS CloudShell 작업

### AWS CLI 버전 확인

```shell
aws --version
```

### AWS 계정 ID 가져오기

```shell
aws sts get-caller-identity --query Account --output text
```

## OpenID Connect Provider

```shell
aws iam create-open-id-connect-provider \
  --url https://token.actions.githubusercontent.com \
  --client-id-list sts.amazonaws.com \
  --thumbprint-list 1234567890123456789012345678901234567890
```


## IAM 역할

### 사용할 리포지터리

「`OWNER`」와 「`REPO`」는 자신의 환경에 맞게 변경

```shell
export GITHUB_REPOSITORY=<OWNER>/<REPO>
```

### Identity Provider의 URL

```shell
export PROVIDER_URL=token.actions.githubusercontent.com
```

### AWS 계정 ID

```shell
export AWS_ID=$(aws sts get-caller-identity --query Account --output text)
```

### IAM 역할명

```shell
export ROLE_NAME=github-actions
```


#### Assume Role 정책을 정의하는 JSON 파일 작성

```shell
cat <<EOF > assume_role_policy.json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Principal": {
        "Federated": "arn:aws:iam::${AWS_ID}:oidc-provider/${PROVIDER_URL}"
      },
      "Condition": {
        "StringLike": {
          "${PROVIDER_URL}:sub": "repo:${GITHUB_REPOSITORY}:*"
        }
      }
    }
  ]
}
EOF
```

#### IAM 역할 작성

```shell
aws iam create-role \
  --role-name $ROLE_NAME \
  --assume-role-policy-document file://assume_role_policy.json
```

#### IAM 정책 추가

```shell
aws iam attach-role-policy \
  --role-name $ROLE_NAME \
  --policy-arn arn:aws:iam::aws:policy/IAMReadOnlyAccess
```


## OpenID Connect를 사용한 AWS 연동

이후는 로컬 환경 작업

### AWS 계정 ID의 시크릿 등록

```shell
gh secret set AWS_ID --body "<AWS 계정ID>"
```


### IAM역할명 시크릿 등록

```shell
gh secret set ROLE_NAME --body "<IAM 역할명>"
```
