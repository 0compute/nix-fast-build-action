{

  flake.seedCfg =
    let

      # SaaS CI/CD providers that:
      #
      # - support OIDC and/or KMS for secure artifact signing
      # - do not require self-hosting of runners or infrastructure
      #
      # schema:
      # cloudProvider (string): underlying cloud provider, if known/applicable
      # geo.strictSovereignty (bool): whether there is a strict legal firewall between regions
      # geo.jurisdiction (list of string): applicable jurisdictions
      # geo.regions (list of string): list of Continent Alpha-2 codes: AS, EU, NA, OC, SA
      # kms (string): KMS signing URL or ARN
      # master (bool): whether this provider is the primary source of truth
      # oidcIssuer (string): OIDC issuer URL
      # ossFree (bool/string): "partial" (limited free tier), true, or false
      # registry (string): container registry URL
      # systems.<system> (list of attrset): hardware details
      # systems.<system>[].name (string): provider runner label
      # systems.<system>[].cpu (string): CPU manufacturer, e.g. "amd", "apple", "graviton", "intel"
      # systems.<system>[].motherboard (string): platform abstraction, e.g. "mac_mini", "virtual"
      # systems.<system>[].os.kernel.name (string): Kernel name, e.g. "darwin", "linux"
      # systems.<system>[].os.kernel.version (string): Kernel version, e.g. "unknown", "6.1"
      # systems.<system>[].os.name (string): OS name, e.g. "macos", "ubuntu"
      # systems.<system>[].os.release (string): OS version, e.g. "13", "22.04"
      # systems.<system>[].ossFree (bool): whether runner is free for open source, overrides provider level
      # systems.<system>[].ram (string): memory abstraction, e.g. "physical", "virtual"
      # systems.<system>[].storage (string): disk type, e.g. "nvme", "ssd", "virtual"
      # systems.<system>[].virtualization (string): environment type, e.g. "bare_metal", "vm"

      builders = {

        # Alibaba Cloud Flow: https://www.alibabacloud.com/help/en/yunxiao
        alibaba = {
          cloudProvider = "Alibaba Cloud";
          geo = {
            strictSovereignty = true;
            jurisdiction = [ "CN" ];
            regions = [ "AS" ];
          };
          # supports KMS signing via sigstore KMS plugin:
          # https://github.com/mozillazg/sigstore-kms-plugin-alibaba-cloud
          kms = "alikms://<region>/<key-id>";
          ossFree = false;
          registry = "registry.cn-hangzhou.aliyuncs.com"; # example registry
          systems = {
            "x86_64-linux" = [
              {
                name = "ubuntu-22.04";
                cpu = "amd";
                motherboard = "virtual";
                os = {
                  kernel = {
                    name = "linux";
                    version = "unknown";
                  };
                  name = "ubuntu";
                  release = "22.04";
                };
                ram = "virtual";
                storage = "virtual";
                virtualization = "vm";
              }
              {
                name = "ubuntu-22.04";
                cpu = "intel";
                motherboard = "virtual";
                os = {
                  kernel = {
                    name = "linux";
                    version = "unknown";
                  };
                  name = "ubuntu";
                  release = "22.04";
                };
                ram = "virtual";
                storage = "virtual";
                virtualization = "vm";
              }
            ];
          };
        };

        # AppVeyor: https://www.appveyor.com/
        appveyor = {
          cloudProvider = "AppVeyor";
          geo = {
            strictSovereignty = false;
            jurisdiction = [ "CA" ];
            regions = [
              "EU"
              "NA"
            ];
          };
          oidcIssuer = "https://oidc.appveyor.com";
          ossFree = "partial"; # limited free tier for OSS
          systems = {
            "x86_64-linux" = [
              {
                name = "ubuntu2204";
                cpu = "amd";
                motherboard = "virtual";
                os = {
                  kernel = {
                    name = "linux";
                    version = "unknown";
                  };
                  name = "ubuntu";
                  release = "22.04";
                };
                ram = "virtual";
                storage = "virtual";
                virtualization = "vm";
              }
              {
                name = "ubuntu2204";
                cpu = "intel";
                motherboard = "virtual";
                os = {
                  kernel = {
                    name = "linux";
                    version = "unknown";
                  };
                  name = "ubuntu";
                  release = "22.04";
                };
                ram = "virtual";
                storage = "virtual";
                virtualization = "vm";
              }
            ];
          };
        };

        # AWS CodeBuild: https://aws.amazon.com/codebuild/
        aws = {
          cloudProvider = "AWS";
          geo = {
            strictSovereignty = false;
            jurisdiction = [ "US" ];
            regions = [
              "AS"
              "EU"
              "NA"
              "OC"
              "SA"
            ];
          };
          # supports OIDC via IAM but often used with KMS
          kms = "arn:aws:kms:<region>:<account>:key/<id>";
          ossFree = "partial"; # limited free tier (usually 100 min/mo)
          registry = "public.ecr.aws";
          systems = {
            "aarch64-linux" = [
              {
                name = "standard:3.0";
                cpu = "graviton";
                motherboard = "virtual";
                os = {
                  kernel = {
                    name = "linux";
                    version = "unknown";
                  };
                  name = "ubuntu";
                  release = "22.04";
                };
                ram = "virtual";
                storage = "virtual";
                virtualization = "vm";
              }
            ];
            "x86_64-linux" = [
              {
                name = "standard:7.0";
                cpu = "amd";
                motherboard = "virtual";
                os = {
                  kernel = {
                    name = "linux";
                    version = "unknown";
                  };
                  name = "ubuntu";
                  release = "22.04";
                };
                ram = "virtual";
                storage = "virtual";
                virtualization = "vm";
              }
              {
                name = "standard:7.0";
                cpu = "intel";
                motherboard = "virtual";
                os = {
                  kernel = {
                    name = "linux";
                    version = "unknown";
                  };
                  name = "ubuntu";
                  release = "22.04";
                };
                ram = "virtual";
                storage = "virtual";
                virtualization = "vm";
              }
            ];
          };
        };

        # Azure Pipelines: https://azure.microsoft.com/en-us/products/devops/pipelines
        azure = {
          cloudProvider = "Azure";
          geo = {
            strictSovereignty = false;
            jurisdiction = [ "US" ];
            regions = [
              "AS"
              "EU"
              "NA"
              "OC"
              "SA"
            ];
          };
          # real issuer is org-scoped:
          # https://vstoken.dev.azure.com/<org-id>
          oidcIssuer = "https://vstoken.dev.azure.com";
          ossFree = true;
          registry = "mcr.microsoft.com";
          systems = {
            "aarch64-darwin" = [
              {
                name = "macOS-15";
                cpu = "apple";
                motherboard = "mac_mini";
                os = {
                  kernel = {
                    name = "darwin";
                    version = "unknown";
                  };
                  name = "macos";
                  release = "15";
                };
                ram = "physical";
                storage = "nvme";
                virtualization = "bare_metal";
              }
              {
                name = "macOS-15";
                cpu = "apple";
                motherboard = "virtual";
                os = {
                  kernel = {
                    name = "darwin";
                    version = "unknown";
                  };
                  name = "macos";
                  release = "15";
                };
                ram = "virtual";
                storage = "virtual";
                virtualization = "vm";
              }
            ];
            "x86_64-darwin" = [
              {
                name = "macOS-13";
                cpu = "intel";
                motherboard = "mac_mini";
                os = {
                  kernel = {
                    name = "darwin";
                    version = "unknown";
                  };
                  name = "macos";
                  release = "13";
                };
                ram = "physical";
                storage = "ssd";
                virtualization = "bare_metal";
              }
              {
                name = "macOS-13";
                cpu = "intel";
                motherboard = "virtual";
                os = {
                  kernel = {
                    name = "darwin";
                    version = "unknown";
                  };
                  name = "macos";
                  release = "13";
                };
                ram = "virtual";
                storage = "virtual";
                virtualization = "vm";
              }
            ];
            "x86_64-linux" = [
              {
                name = "ubuntu-24.04";
                cpu = "amd";
                motherboard = "virtual";
                os = {
                  kernel = {
                    name = "linux";
                    version = "unknown";
                  };
                  name = "ubuntu";
                  release = "24.04";
                };
                ram = "virtual";
                storage = "virtual";
                virtualization = "vm";
              }
              {
                name = "ubuntu-24.04";
                cpu = "intel";
                motherboard = "virtual";
                os = {
                  kernel = {
                    name = "linux";
                    version = "unknown";
                  };
                  name = "ubuntu";
                  release = "24.04";
                };
                ram = "virtual";
                storage = "virtual";
                virtualization = "vm";
              }
            ];
          };
        };

        # Bitbucket Pipelines: https://bitbucket.org/product/features/pipelines
        bitbucket = {
          cloudProvider = "AWS";
          geo = {
            strictSovereignty = false;
            jurisdiction = [ "AU" ];
            regions = [
              "AS"
              "EU"
              "NA"
              "OC"
            ];
          };
          # workspace-scoped issuer in practice
          oidcIssuer = "https://api.bitbucket.org/2.0/workspaces";
          ossFree = "partial"; # 50 min/mo on free tier
          systems = {
            "aarch64-linux" = [
              {
                name = "arm64";
                cpu = "graviton";
                motherboard = "virtual";
                os = {
                  kernel = {
                    name = "linux";
                    version = "unknown";
                  };
                  name = "ubuntu";
                  release = "22.04";
                };
                ram = "virtual";
                storage = "virtual";
                virtualization = "vm";
              }
            ];
            "x86_64-linux" = [
              {
                name = "ubuntu-22.04";
                cpu = "amd";
                motherboard = "virtual";
                os = {
                  kernel = {
                    name = "linux";
                    version = "unknown";
                  };
                  name = "ubuntu";
                  release = "22.04";
                };
                ram = "virtual";
                storage = "virtual";
                virtualization = "vm";
              }
              {
                name = "ubuntu-22.04";
                cpu = "intel";
                motherboard = "virtual";
                os = {
                  kernel = {
                    name = "linux";
                    version = "unknown";
                  };
                  name = "ubuntu";
                  release = "22.04";
                };
                ram = "virtual";
                storage = "virtual";
                virtualization = "vm";
              }
            ];
          };
        };

        # Bitrise: https://bitrise.io/
        bitrise = {
          cloudProvider = "GCP";
          geo = {
            strictSovereignty = false;
            jurisdiction = [
              "EU"
              "HU"
            ];
            regions = [
              "EU"
              "NA"
            ];
          };
          oidcIssuer = "https://oidc.bitrise.io";
          ossFree = "partial"; # credit-based free tier
          systems = {
            "aarch64-linux" = [
              {
                name = "ubuntu-22-04-arm64";
                cpu = "ampere";
                motherboard = "virtual";
                os = {
                  kernel = {
                    name = "linux";
                    version = "unknown";
                  };
                  name = "ubuntu";
                  release = "22.04";
                };
                ram = "virtual";
                storage = "virtual";
                virtualization = "vm";
              }
              {
                name = "ubuntu-22-04-arm64";
                cpu = "graviton";
                motherboard = "virtual";
                os = {
                  kernel = {
                    name = "linux";
                    version = "unknown";
                  };
                  name = "ubuntu";
                  release = "22.04";
                };
                ram = "virtual";
                storage = "virtual";
                virtualization = "vm";
              }
            ];
            "x86_64-linux" = [
              {
                name = "ubuntu-22-04-x86_64";
                cpu = "amd";
                motherboard = "virtual";
                os = {
                  kernel = {
                    name = "linux";
                    version = "unknown";
                  };
                  name = "ubuntu";
                  release = "22.04";
                };
                ram = "virtual";
                storage = "virtual";
                virtualization = "vm";
              }
              {
                name = "ubuntu-22-04-x86_64";
                cpu = "intel";
                motherboard = "virtual";
                os = {
                  kernel = {
                    name = "linux";
                    version = "unknown";
                  };
                  name = "ubuntu";
                  release = "22.04";
                };
                ram = "virtual";
                storage = "virtual";
                virtualization = "vm";
              }
            ];
          };
        };

        # Buddy: https://buddy.works/
        buddy = {
          cloudProvider = "AWS";
          geo = {
            strictSovereignty = false;
            jurisdiction = [
              "EU"
              "PL"
            ];
            regions = [
              "EU"
              "NA"
            ];
          };
          # region-scoped issuer in practice:
          # https://[eu-]oidc.buddyusercontent.com
          oidcIssuer = "https://oidc.buddyusercontent.com";
          ossFree = "partial"; # limited free tier
          systems = {
            "x86_64-linux" = [
              {
                name = "ubuntu/22.04";
                cpu = "amd";
                motherboard = "virtual";
                os = {
                  kernel = {
                    name = "linux";
                    version = "unknown";
                  };
                  name = "ubuntu";
                  release = "22.04";
                };
                ram = "virtual";
                storage = "virtual";
                virtualization = "vm";
              }
              {
                name = "ubuntu/22.04";
                cpu = "intel";
                motherboard = "virtual";
                os = {
                  kernel = {
                    name = "linux";
                    version = "unknown";
                  };
                  name = "ubuntu";
                  release = "22.04";
                };
                ram = "virtual";
                storage = "virtual";
                virtualization = "vm";
              }
            ];
          };
        };

        # Buildkite: https://buildkite.com/
        buildkite = {
          cloudProvider = "AWS";
          geo = {
            strictSovereignty = false;
            jurisdiction = [ "AU" ];
            regions = [
              "EU"
              "NA"
              "OC"
            ];
          };
          oidcIssuer = "https://agent.buildkite.com";
          ossFree = false; # requires application/approval for open source plan
          systems = {
            "aarch64-linux" = [
              {
                name = "linux-arm64-instance-2";
                cpu = "graviton";
                motherboard = "virtual";
                os = {
                  kernel = {
                    name = "linux";
                    version = "unknown";
                  };
                  name = "ubuntu";
                  release = "22.04";
                };
                ram = "virtual";
                storage = "virtual";
                virtualization = "vm";
              }
            ];
            "x86_64-linux" = [
              {
                name = "linux-amd64-instance-2";
                cpu = "amd";
                motherboard = "virtual";
                os = {
                  kernel = {
                    name = "linux";
                    version = "unknown";
                  };
                  name = "ubuntu";
                  release = "22.04";
                };
                ram = "virtual";
                storage = "virtual";
                virtualization = "vm";
              }
              {
                name = "linux-amd64-instance-2";
                cpu = "intel";
                motherboard = "virtual";
                os = {
                  kernel = {
                    name = "linux";
                    version = "unknown";
                  };
                  name = "ubuntu";
                  release = "22.04";
                };
                ram = "virtual";
                storage = "virtual";
                virtualization = "vm";
              }
            ];
          };
        };

        # CircleCI: https://circleci.com/
        circleci = {
          cloudProvider = "AWS";
          geo = {
            strictSovereignty = false;
            jurisdiction = [ "US" ];
            regions = [
              "EU"
              "NA"
            ];
          };
          # real issuer is org-scoped:
          # https://oidc.circleci.com/org/<org-id>
          oidcIssuer = "https://oidc.circleci.com";
          ossFree = true;
          systems = {
            "aarch64-darwin" = [
              {
                name = "macos.m2.medium.gen1";
                cpu = "apple";
                motherboard = "mac_mini";
                os = {
                  kernel = {
                    name = "darwin";
                    version = "unknown";
                  };
                  name = "macos";
                  release = "14";
                };
                ram = "physical";
                storage = "nvme";
                virtualization = "bare_metal";
              }
              {
                name = "macos.m2.large.gen1";
                cpu = "apple";
                motherboard = "virtual";
                ossFree = false;
                os = {
                  kernel = {
                    name = "darwin";
                    version = "unknown";
                  };
                  name = "macos";
                  release = "14";
                };
                ram = "virtual";
                storage = "virtual";
                virtualization = "vm";
              }
            ];
            "aarch64-linux" = [
              {
                name = "arm.medium";
                cpu = "graviton";
                motherboard = "virtual";
                os = {
                  kernel = {
                    name = "linux";
                    version = "unknown";
                  };
                  name = "ubuntu";
                  release = "22.04";
                };
                ram = "virtual";
                storage = "virtual";
                virtualization = "vm";
              }
            ];
            "x86_64-darwin" = [
              {
                name = "macos.x86.medium.gen2";
                cpu = "intel";
                motherboard = "mac_mini";
                os = {
                  kernel = {
                    name = "darwin";
                    version = "unknown";
                  };
                  name = "macos";
                  release = "13";
                };
                ram = "physical";
                storage = "ssd";
                virtualization = "bare_metal";
              }
              {
                name = "macos.x86.large.gen2";
                cpu = "intel";
                motherboard = "virtual";
                ossFree = false;
                os = {
                  kernel = {
                    name = "darwin";
                    version = "unknown";
                  };
                  name = "macos";
                  release = "13";
                };
                ram = "virtual";
                storage = "virtual";
                virtualization = "vm";
              }
            ];
            "x86_64-linux" = [
              {
                name = "medium";
                cpu = "amd";
                motherboard = "virtual";
                os = {
                  kernel = {
                    name = "linux";
                    version = "unknown";
                  };
                  name = "ubuntu";
                  release = "22.04";
                };
                ram = "virtual";
                storage = "virtual";
                virtualization = "vm";
              }
              {
                name = "medium";
                cpu = "intel";
                motherboard = "virtual";
                os = {
                  kernel = {
                    name = "linux";
                    version = "unknown";
                  };
                  name = "ubuntu";
                  release = "22.04";
                };
                ram = "virtual";
                storage = "virtual";
                virtualization = "vm";
              }
            ];
          };
        };

        # Codefresh: https://codefresh.io/
        codefresh = {
          cloudProvider = "GCP";
          geo = {
            strictSovereignty = false;
            jurisdiction = [ "US" ];
            regions = [
              "EU"
              "NA"
            ];
          };
          oidcIssuer = "https://oidc.codefresh.io";
          ossFree = "partial"; # limited free tier
          registry = "r.cfcr.io";
          systems = {
            "x86_64-linux" = [
              {
                name = "ubuntu-22.04";
                cpu = "amd";
                motherboard = "virtual";
                os = {
                  kernel = {
                    name = "linux";
                    version = "unknown";
                  };
                  name = "ubuntu";
                  release = "22.04";
                };
                ram = "virtual";
                storage = "virtual";
                virtualization = "vm";
              }
              {
                name = "ubuntu-22.04";
                cpu = "intel";
                motherboard = "virtual";
                os = {
                  kernel = {
                    name = "linux";
                    version = "unknown";
                  };
                  name = "ubuntu";
                  release = "22.04";
                };
                ram = "virtual";
                storage = "virtual";
                virtualization = "vm";
              }
            ];
          };
        };

        # Codemagic: https://codemagic.io/
        codemagic = {
          cloudProvider = "MacStadium";
          geo = {
            strictSovereignty = false;
            jurisdiction = [
              "EE"
              "EU"
            ];
            regions = [
              "EU"
              "NA"
            ];
          };
          oidcIssuer = "https://codemagic.io";
          ossFree = "partial"; # credit-based free tier
          systems = {
            "aarch64-linux" = [
              {
                name = "linux-arm64";
                cpu = "ampere";
                motherboard = "virtual";
                os = {
                  kernel = {
                    name = "linux";
                    version = "unknown";
                  };
                  name = "ubuntu";
                  release = "22.04";
                };
                ram = "virtual";
                storage = "virtual";
                virtualization = "vm";
              }
              {
                name = "linux-arm64";
                cpu = "graviton";
                motherboard = "virtual";
                os = {
                  kernel = {
                    name = "linux";
                    version = "unknown";
                  };
                  name = "ubuntu";
                  release = "22.04";
                };
                ram = "virtual";
                storage = "virtual";
                virtualization = "vm";
              }
            ];
            "x86_64-linux" = [
              {
                name = "linux-x64";
                cpu = "amd";
                motherboard = "virtual";
                os = {
                  kernel = {
                    name = "linux";
                    version = "unknown";
                  };
                  name = "ubuntu";
                  release = "22.04";
                };
                ram = "virtual";
                storage = "virtual";
                virtualization = "vm";
              }
              {
                name = "linux-x64";
                cpu = "intel";
                motherboard = "virtual";
                os = {
                  kernel = {
                    name = "linux";
                    version = "unknown";
                  };
                  name = "ubuntu";
                  release = "22.04";
                };
                ram = "virtual";
                storage = "virtual";
                virtualization = "vm";
              }
            ];
          };
        };

        # Fly.io: https://fly.io/
        fly = {
          cloudProvider = "Fly.io";
          geo = {
            strictSovereignty = false;
            jurisdiction = [ "US" ];
            regions = [
              "AS"
              "EU"
              "NA"
              "OC"
              "SA"
            ];
          };
          oidcIssuer = "https://oidc.fly.io";
          ossFree = "partial"; # free allowance for small VMs
          systems = {
            "x86_64-linux" = [
              {
                name = "ubuntu-22.04";
                cpu = "amd";
                motherboard = "virtual";
                os = {
                  kernel = {
                    name = "linux";
                    version = "unknown";
                  };
                  name = "ubuntu";
                  release = "22.04";
                };
                ram = "virtual";
                storage = "virtual";
                virtualization = "vm";
              }
              {
                name = "ubuntu-22.04";
                cpu = "intel";
                motherboard = "virtual";
                os = {
                  kernel = {
                    name = "linux";
                    version = "unknown";
                  };
                  name = "ubuntu";
                  release = "22.04";
                };
                ram = "virtual";
                storage = "virtual";
                virtualization = "vm";
              }
            ];
          };
        };

        # Google Cloud Build: https://cloud.google.com/build
        gcb = {
          cloudProvider = "GCP";
          geo = {
            strictSovereignty = false;
            jurisdiction = [ "US" ];
            regions = [
              "AS"
              "EU"
              "NA"
              "OC"
              "SA"
            ];
          };
          # supports OIDC via accounts.google.com but often used with Cloud KMS
          kms = "projects/*/locations/*/keyRings/*/cryptoKeys/*";
          oidcIssuer = "https://accounts.google.com";
          ossFree = "partial"; # first 120 build-minutes/day free
          registry = "gcr.io";
          systems = {
            "x86_64-linux" = [
              {
                name = "ubuntu-22.04";
                cpu = "amd";
                motherboard = "virtual";
                os = {
                  kernel = {
                    name = "linux";
                    version = "unknown";
                  };
                  name = "ubuntu";
                  release = "22.04";
                };
                ram = "virtual";
                storage = "virtual";
                virtualization = "vm";
              }
              {
                name = "ubuntu-22.04";
                cpu = "intel";
                motherboard = "virtual";
                os = {
                  kernel = {
                    name = "linux";
                    version = "unknown";
                  };
                  name = "ubuntu";
                  release = "22.04";
                };
                ram = "virtual";
                storage = "virtual";
                virtualization = "vm";
              }
            ];
          };
        };

        # GitHub Actions: https://github.com/features/actions
        github = {
          cloudProvider = "Azure";
          geo = {
            strictSovereignty = false;
            jurisdiction = [ "US" ];
            regions = [
              "AS"
              "EU"
              "NA"
              "OC"
              "SA"
            ];
          };
          # TODO: enforce unique
          master = true;
          oidcIssuer = "https://token.actions.githubusercontent.com";
          ossFree = true;
          registry = "ghcr.io";
          systems = {
            "aarch64-darwin" = [
              {
                name = "macos-15";
                cpu = "apple";
                motherboard = "mac_mini";
                os = {
                  kernel = {
                    name = "darwin";
                    version = "unknown";
                  };
                  name = "macos";
                  release = "15";
                };
                ram = "physical";
                storage = "nvme";
                virtualization = "bare_metal";
              }
              {
                name = "macos-15-xlarge";
                cpu = "apple";
                motherboard = "virtual";
                ossFree = false;
                os = {
                  kernel = {
                    name = "darwin";
                    version = "unknown";
                  };
                  name = "macos";
                  release = "15";
                };
                ram = "virtual";
                storage = "virtual";
                virtualization = "vm";
              }
            ];
            "aarch64-linux" = [
              {
                name = "ubuntu-24.04-arm";
                cpu = "ampere";
                motherboard = "virtual";
                os = {
                  kernel = {
                    name = "linux";
                    version = "unknown";
                  };
                  name = "ubuntu";
                  release = "24.04";
                };
                ram = "virtual";
                storage = "virtual";
                virtualization = "vm";
              }
              {
                name = "ubuntu-24.04-arm";
                cpu = "graviton";
                motherboard = "virtual";
                os = {
                  kernel = {
                    name = "linux";
                    version = "unknown";
                  };
                  name = "ubuntu";
                  release = "24.04";
                };
                ram = "virtual";
                storage = "virtual";
                virtualization = "vm";
              }
            ];
            "x86_64-darwin" = [
              {
                name = "macos-13";
                cpu = "intel";
                motherboard = "mac_mini";
                os = {
                  kernel = {
                    name = "darwin";
                    version = "unknown";
                  };
                  name = "macos";
                  release = "13";
                };
                ram = "physical";
                storage = "ssd";
                virtualization = "bare_metal";
              }
              {
                name = "macos-13-xlarge";
                cpu = "intel";
                motherboard = "virtual";
                ossFree = false;
                os = {
                  kernel = {
                    name = "darwin";
                    version = "unknown";
                  };
                  name = "macos";
                  release = "13";
                };
                ram = "virtual";
                storage = "virtual";
                virtualization = "vm";
              }
            ];
            "x86_64-linux" = [
              {
                name = "ubuntu-24.04";
                cpu = "amd";
                motherboard = "virtual";
                os = {
                  kernel = {
                    name = "linux";
                    version = "unknown";
                  };
                  name = "ubuntu";
                  release = "24.04";
                };
                ram = "virtual";
                storage = "virtual";
                virtualization = "vm";
              }
              {
                name = "ubuntu-24.04";
                cpu = "intel";
                motherboard = "virtual";
                os = {
                  kernel = {
                    name = "linux";
                    version = "unknown";
                  };
                  name = "ubuntu";
                  release = "24.04";
                };
                ram = "virtual";
                storage = "virtual";
                virtualization = "vm";
              }
            ];
          };
        };

        # GitLab CI: https://docs.gitlab.com/ee/ci/
        gitlab = {
          cloudProvider = "GCP";
          geo = {
            strictSovereignty = false;
            jurisdiction = [ "US" ];
            regions = [
              "AS"
              "EU"
              "NA"
              "OC"
              "SA"
            ];
          };
          oidcIssuer = "https://gitlab.com";
          ossFree = true;
          registry = "registry.gitlab.com";
          systems = {
            "aarch64-darwin" = [
              {
                name = "saas-macos-medium-m2";
                cpu = "apple";
                motherboard = "mac_mini";
                ossFree = false;
                os = {
                  kernel = {
                    name = "darwin";
                    version = "unknown";
                  };
                  name = "macos";
                  release = "14";
                };
                ram = "physical";
                storage = "nvme";
                virtualization = "bare_metal";
              }
              {
                name = "saas-macos-large-m2";
                cpu = "apple";
                motherboard = "virtual";
                ossFree = false;
                os = {
                  kernel = {
                    name = "darwin";
                    version = "unknown";
                  };
                  name = "macos";
                  release = "14";
                };
                ram = "virtual";
                storage = "virtual";
                virtualization = "vm";
              }
            ];
            "aarch64-linux" = [
              {
                name = "saas-linux-medium-arm64";
                cpu = "ampere";
                motherboard = "virtual";
                os = {
                  kernel = {
                    name = "linux";
                    version = "unknown";
                  };
                  name = "ubuntu";
                  release = "22.04";
                };
                ram = "virtual";
                storage = "virtual";
                virtualization = "vm";
              }
              {
                name = "saas-linux-small-arm64";
                cpu = "graviton";
                motherboard = "virtual";
                os = {
                  kernel = {
                    name = "linux";
                    version = "unknown";
                  };
                  name = "ubuntu";
                  release = "22.04";
                };
                ram = "virtual";
                storage = "virtual";
                virtualization = "vm";
              }
            ];
            "x86_64-darwin" = [
              {
                name = "saas-macos-medium-amd64";
                cpu = "intel";
                motherboard = "mac_mini";
                ossFree = false;
                os = {
                  kernel = {
                    name = "darwin";
                    version = "unknown";
                  };
                  name = "macos";
                  release = "13";
                };
                ram = "physical";
                storage = "ssd";
                virtualization = "bare_metal";
              }
              {
                name = "saas-macos-large-amd64";
                cpu = "intel";
                motherboard = "virtual";
                ossFree = false;
                os = {
                  kernel = {
                    name = "darwin";
                    version = "unknown";
                  };
                  name = "macos";
                  release = "13";
                };
                ram = "virtual";
                storage = "virtual";
                virtualization = "vm";
              }
            ];
            "x86_64-linux" = [
              {
                name = "saas-linux-medium-amd64";
                cpu = "amd";
                motherboard = "virtual";
                os = {
                  kernel = {
                    name = "linux";
                    version = "unknown";
                  };
                  name = "ubuntu";
                  release = "22.04";
                };
                ram = "virtual";
                storage = "virtual";
                virtualization = "vm";
              }
              {
                name = "saas-linux-large-amd64";
                cpu = "intel";
                motherboard = "virtual";
                ossFree = false;
                os = {
                  kernel = {
                    name = "linux";
                    version = "unknown";
                  };
                  name = "ubuntu";
                  release = "22.04";
                };
                ram = "virtual";
                storage = "virtual";
                virtualization = "vm";
              }
            ];
          };
        };

        # Harness CI: https://harness.io/products/continuous-integration
        harness = {
          cloudProvider = "GCP";
          geo = {
            strictSovereignty = false;
            jurisdiction = [ "US" ];
            regions = [
              "EU"
              "NA"
            ];
          };
          # real issuer is account-scoped:
          # https://app.harness.io/ng/api/oidc/account/<account-id>
          oidcIssuer = "https://app.harness.io";
          ossFree = "partial"; # "Free Forever" tier with limited usage/features
          systems = {
            "aarch64-linux" = [
              {
                name = "linux-arm64";
                cpu = "ampere";
                motherboard = "virtual";
                os = {
                  kernel = {
                    name = "linux";
                    version = "unknown";
                  };
                  name = "ubuntu";
                  release = "22.04";
                };
                ram = "virtual";
                storage = "virtual";
                virtualization = "vm";
              }
              {
                name = "linux-arm64";
                cpu = "graviton";
                motherboard = "virtual";
                os = {
                  kernel = {
                    name = "linux";
                    version = "unknown";
                  };
                  name = "ubuntu";
                  release = "22.04";
                };
                ram = "virtual";
                storage = "virtual";
                virtualization = "vm";
              }
            ];
            "x86_64-linux" = [
              {
                name = "linux-amd64";
                cpu = "amd";
                motherboard = "virtual";
                os = {
                  kernel = {
                    name = "linux";
                    version = "unknown";
                  };
                  name = "ubuntu";
                  release = "22.04";
                };
                ram = "virtual";
                storage = "virtual";
                virtualization = "vm";
              }
              {
                name = "linux-amd64";
                cpu = "intel";
                motherboard = "virtual";
                os = {
                  kernel = {
                    name = "linux";
                    version = "unknown";
                  };
                  name = "ubuntu";
                  release = "22.04";
                };
                ram = "virtual";
                storage = "virtual";
                virtualization = "vm";
              }
            ];
          };
        };

        # Scaleway: https://www.scaleway.com/
        scaleway = {
          cloudProvider = "Scaleway";
          geo = {
            strictSovereignty = false;
            jurisdiction = [
              "EU"
              "FR"
            ];
            regions = [ "EU" ];
          };
          oidcIssuer = "https://oidc.scaleway.com";
          ossFree = "partial"; # limited free tier
          systems = {
            "x86_64-linux" = [
              {
                name = "ubuntu-22.04";
                cpu = "amd";
                motherboard = "virtual";
                os = {
                  kernel = {
                    name = "linux";
                    version = "unknown";
                  };
                  name = "ubuntu";
                  release = "22.04";
                };
                ram = "virtual";
                storage = "virtual";
                virtualization = "vm";
              }
              {
                name = "ubuntu-22.04";
                cpu = "intel";
                motherboard = "virtual";
                os = {
                  kernel = {
                    name = "linux";
                    version = "unknown";
                  };
                  name = "ubuntu";
                  release = "22.04";
                };
                ram = "virtual";
                storage = "virtual";
                virtualization = "vm";
              }
            ];
          };
        };

        # Semaphore: https://semaphoreci.com/
        semaphore = {
          cloudProvider = "GCP";
          geo = {
            strictSovereignty = false;
            jurisdiction = [
              "EU"
              "HR"
            ];
            regions = [
              "EU"
              "NA"
            ];
          };
          # real issuer is org-scoped:
          # https://<org>.semaphoreci.com
          oidcIssuer = "https://semaphoreci.com";
          ossFree = "partial"; # limited free tier (credits based)
          systems = {
            "aarch64-linux" = [
              {
                name = "ubuntu2204:current";
                cpu = "ampere";
                motherboard = "virtual";
                os = {
                  kernel = {
                    name = "linux";
                    version = "unknown";
                  };
                  name = "ubuntu";
                  release = "22.04";
                };
                ram = "virtual";
                storage = "virtual";
                virtualization = "vm";
              }
              {
                name = "ubuntu2204:current";
                cpu = "graviton";
                motherboard = "virtual";
                os = {
                  kernel = {
                    name = "linux";
                    version = "unknown";
                  };
                  name = "ubuntu";
                  release = "22.04";
                };
                ram = "virtual";
                storage = "virtual";
                virtualization = "vm";
              }
            ];
            "x86_64-linux" = [
              {
                name = "ubuntu2204:current";
                cpu = "amd";
                motherboard = "virtual";
                os = {
                  kernel = {
                    name = "linux";
                    version = "unknown";
                  };
                  name = "ubuntu";
                  release = "22.04";
                };
                ram = "virtual";
                storage = "virtual";
                virtualization = "vm";
              }
              {
                name = "ubuntu2204:current";
                cpu = "intel";
                motherboard = "virtual";
                os = {
                  kernel = {
                    name = "linux";
                    version = "unknown";
                  };
                  name = "ubuntu";
                  release = "22.04";
                };
                ram = "virtual";
                storage = "virtual";
                virtualization = "vm";
              }
            ];
          };
        };

        # Spacelift: https://spacelift.io/
        spacelift = {
          cloudProvider = "AWS";
          geo = {
            strictSovereignty = false;
            jurisdiction = [ "US" ];
            regions = [
              "EU"
              "NA"
            ];
          };
          # real issuer is account-scoped:
          # https://<account>.app.spacelift.io
          oidcIssuer = "https://app.spacelift.io";
          ossFree = false;
          systems = {
            "x86_64-linux" = [
              {
                name = "ubuntu-22.04";
                cpu = "amd";
                motherboard = "virtual";
                os = {
                  kernel = {
                    name = "linux";
                    version = "unknown";
                  };
                  name = "ubuntu";
                  release = "22.04";
                };
                ram = "virtual";
                storage = "virtual";
                virtualization = "vm";
              }
              {
                name = "ubuntu-22.04";
                cpu = "intel";
                motherboard = "virtual";
                os = {
                  kernel = {
                    name = "linux";
                    version = "unknown";
                  };
                  name = "ubuntu";
                  release = "22.04";
                };
                ram = "virtual";
                storage = "virtual";
                virtualization = "vm";
              }
            ];
          };
        };

        # HCP Terraform: https://www.hashicorp.com/products/terraform
        terraform = {
          cloudProvider = "AWS";
          geo = {
            strictSovereignty = false;
            jurisdiction = [ "US" ];
            regions = [
              "EU"
              "NA"
            ];
          };
          oidcIssuer = "https://app.terraform.io";
          ossFree = false;
          systems = {
            "x86_64-linux" = [
              {
                name = "ubuntu-22.04";
                cpu = "amd";
                motherboard = "virtual";
                os = {
                  kernel = {
                    name = "linux";
                    version = "unknown";
                  };
                  name = "ubuntu";
                  release = "22.04";
                };
                ram = "virtual";
                storage = "virtual";
                virtualization = "vm";
              }
              {
                name = "ubuntu-22.04";
                cpu = "intel";
                motherboard = "virtual";
                os = {
                  kernel = {
                    name = "linux";
                    version = "unknown";
                  };
                  name = "ubuntu";
                  release = "22.04";
                };
                ram = "virtual";
                storage = "virtual";
                virtualization = "vm";
              }
            ];
          };
        };

        # Vercel: https://vercel.com/
        vercel = {
          cloudProvider = "AWS";
          geo = {
            strictSovereignty = false;
            jurisdiction = [ "US" ];
            regions = [
              "AS"
              "EU"
              "NA"
              "OC"
              "SA"
            ];
          };
          # real issuer is team-scoped:
          # https://oidc.vercel.com/[team-slug]
          oidcIssuer = "https://oidc.vercel.com";
          ossFree = true;
          systems = {
            "x86_64-linux" = [
              {
                name = "ubuntu-22.04";
                cpu = "amd";
                motherboard = "virtual";
                os = {
                  kernel = {
                    name = "linux";
                    version = "unknown";
                  };
                  name = "ubuntu";
                  release = "22.04";
                };
                ram = "virtual";
                storage = "virtual";
                virtualization = "vm";
              }
              {
                name = "ubuntu-22.04";
                cpu = "intel";
                motherboard = "virtual";
                os = {
                  kernel = {
                    name = "linux";
                    version = "unknown";
                  };
                  name = "ubuntu";
                  release = "22.04";
                };
                ram = "virtual";
                storage = "virtual";
                virtualization = "vm";
              }
            ];
          };
        };

      };

      fallbackRegistry = builders.github.registry;

      rekor = {
        url = "https://rekor.sigstore.dev";
        # quorum unspecified means unanimous
        quorum = 5;
        deadline = "30m";
      };

    in
    {
      inherit fallbackRegistry builders rekor;
    };

}
