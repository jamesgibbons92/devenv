/// <reference path="./.sst/platform/config.d.ts" />
const amis = {
  "eu-west-1": "ami-0224687480f8cbcba",
  "eu-west-2": "ami-04ed5679783ced6bf",
};
export default $config({
  app(_) {
    return {
      name: "workstation",
      home: "aws",
      providers: { tls: "5.2.0" },
    };
  },
  async run() {
    const vpc = new sst.aws.Vpc("Vpc", {
      bastion: true,
      nat: "managed",
      az: 1,
      transform: {
        bastionSecurityGroup: {
          ingress: [
            {
              fromPort: 0,
              toPort: 0,
              cidrBlocks: [
                $interpolate`${fetch("https://icanhazip.com").then((res) =>
                  res.text().then((ip) => `${ip.trim()}/32`)
                )}`,
              ],
              protocol: "-1",
            },
          ],
        },
      },
    });

    const sg = new aws.ec2.SecurityGroup("SecurityGroup", {
      vpcId: vpc.id,
      ingress: [
        {
          protocol: "tcp",
          fromPort: 22,
          toPort: 22,
          cidrBlocks: [vpc.nodes.vpc.cidrBlock],
        },
      ],
      egress: [
        {
          protocol: "-1",
          fromPort: 0,
          toPort: 0,
          cidrBlocks: ["0.0.0.0/0"],
        },
      ],
    });

    const ami = amis[aws.config.region || ""];
    if (!ami) {
      throw new Error(`No AMI found for region ${aws.config.region}`);
    }

    const privateKey = new tls.PrivateKey("PrivateKey", {
      algorithm: "ED25519",
    });

    const sshKey = new aws.ec2.KeyPair("SshKey", {
      publicKey: privateKey.publicKeyOpenssh,
    });

    const server = new aws.ec2.Instance("Server", {
      instanceType: "t3a.2xlarge",
      ami: ami,
      rootBlockDevice: {
        volumeSize: 250,
      },
      vpcSecurityGroupIds: [sg.id],
      subnetId: vpc.privateSubnets[0].apply((subnet) => subnet),
      keyName: sshKey.keyName,
      tags: {
        Name: "workstation",
      },
    });

    return {
      ip: server.privateIp,
      key: privateKey.privateKeyOpenssh,
    };
  },
});
