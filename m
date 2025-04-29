Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 19FC3C3ABAB
	for <lustre-devel@archiver.kernel.org>; Tue, 29 Apr 2025 14:31:16 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Zn2mq0FQsz1xSJ;
	Tue, 29 Apr 2025 07:31:07 -0700 (PDT)
Received: from outbound-ip168a.ess.barracuda.com
 (outbound-ip168a.ess.barracuda.com [209.222.82.36])
 (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Zn2md0z1Fz1xS3; Tue, 29 Apr 2025 07:30:57 -0700 (PDT)
Received: from NAM12-BN8-obe.outbound.protection.outlook.com
 (mail-bn8nam12lp2169.outbound.protection.outlook.com [104.47.55.169]) by
 mx-outbound8-233.us-east-2a.ess.aws.cudaops.com (version=TLSv1.2
 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
 Tue, 29 Apr 2025 14:30:52 +0000
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=pqKrj2KM+LZ0HUEO+ixEZ25ZBPAMJ8wqPir/t3UMY4/jSKSo3jpTOsWNDzekKVwq6uiJSm2FSLnFNGRGZBqogOcKTtJQuAVBLzexpJwl9cJiphpnMVbru0c0DPnhtjOG95GEvEZQP4VNQiwR/ELjUlzcKLHRuGWx08YjwLMAPrajbUpiOjCOVb2jhi1RfPOSE05/bFWza2mjkvB+xky7+hZS+fswDTtFmaG6W2/XPE+EGOxzvFHDaDPopWzoHgfQFEpnkBJs/UMLXHf8Fqzq1rlMJzOr07PoDldBNyOT07Z+na5bjp/NAn04bv+5ZkjioFOFb70zUeHpYn617w3u+Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com; 
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=COX68o0r0SxrRkNkL4kMhMLahqWJeClgbTnk5XZtyq4=;
 b=B9PEDOJHRTKOwBk9iGoMvjDrVp0I7JXNcHjVuTLpDQEEzmjL3OGxqlYqKUpSDy0BuBhpu/PLzVTYz7mTbxkjckm3TXQ5HXagiJI/+jtajejaXSkcX1QjRt/fnjGPkXdX804wSEB4cHFcYUT7DZkl+HUqHTo2PTvkr2G9/BPq1daPo5UlAJKnlo8r+jhyT0+Dyq+n5tATBE6eDNDOibx5y2ujN31OhDRHVCl+6II9okVndVuf2QYHEjrXlMI7+i0DqVL9Oot6+p4rbnUOC0JihSg1+jGQkcfoPI3uJM780boValJzP3olfCIVSrXqBhfKBtPphisuzAjcISE0Kk8K8g==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=ddn.com; dmarc=pass action=none header.from=ddn.com; dkim=pass
 header.d=ddn.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ddn.com; s=selector2; 
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=COX68o0r0SxrRkNkL4kMhMLahqWJeClgbTnk5XZtyq4=;
 b=pXhhDMUjBbAfZ7EYpzDV4U1ffVU9vBBHRt4AYYuQ1AdI8xrjbi2p5zUKVT/1jVcoIVTgbDZ2qGNT9eO1b8qhdGvlkbdhTDFuHAbUH9wYHMlbq0wF1sCoogqE7Z2PfJtQahi5Xe6O4n46fVxAewvj6IUSJV99KoCX7NJfdfgpz08=
Received: from DM6PR19MB2636.namprd19.prod.outlook.com (2603:10b6:5:15f::15)
 by SA6PR19MB8673.namprd19.prod.outlook.com (2603:10b6:806:417::15) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.8678.31; Tue, 29 Apr
 2025 14:30:48 +0000
Received: from DM6PR19MB2636.namprd19.prod.outlook.com
 ([fe80::48f4:9756:558e:f02c]) by DM6PR19MB2636.namprd19.prod.outlook.com
 ([fe80::48f4:9756:558e:f02c%5]) with mapi id 15.20.8678.028; Tue, 29 Apr 2025
 14:30:48 +0000
From: Patrick Farrell <pfarrell@ddn.com>
To: Andreas Dilger <adilger@ddn.com>, GEORGE ZHAO <georgezhaojobs@gmail.com>
CC: "lustre-discuss@lists.lustre.org" <lustre-discuss@lists.lustre.org>,
 "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>
Thread-Topic: [lustre-discuss] Beginner: Lustre server compile and deploy
Thread-Index: AQHbuFByhmi0cPH7ZkC9I1GnjlqpebO5s0WAgAECWwY=
Date: Tue, 29 Apr 2025 14:30:48 +0000
Message-ID: <DM6PR19MB26366C743933C2132E4BDBA1C9802@DM6PR19MB2636.namprd19.prod.outlook.com>
References: <CAFhHJgm+7QRV39wR2GB+Q2nASTg8NchXQPpqjFe_KPa0sUPqpw@mail.gmail.com>
 <66BA42BA-AA8C-4D6D-B268-CEA2D8214938@ddn.com>
In-Reply-To: <66BA42BA-AA8C-4D6D-B268-CEA2D8214938@ddn.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=ddn.com;
x-ms-publictraffictype: Email
x-ms-traffictypediagnostic: DM6PR19MB2636:EE_|SA6PR19MB8673:EE_
x-ms-office365-filtering-correlation-id: 9bd62255-3a1f-44a1-c6f0-08dd872a6f4c
x-ms-exchange-senderadcheck: 1
x-ms-exchange-antispam-relay: 0
x-microsoft-antispam: BCL:0;
 ARA:13230040|376014|1800799024|366016|13003099007|8096899003|7053199007|38070700018;
x-microsoft-antispam-message-info: =?Windows-1252?Q?iXmHWz3uZ3KGvhAvlqTVcBjgjLBs6FcT7JKM7Y1qXx1Hc6IDCyVjrh5W?=
 =?Windows-1252?Q?/lVdtZWrJOTIxPKIzGpTAZUbS4BhLtDV5NfrZ3j12DEMqDOsrjz00G4a?=
 =?Windows-1252?Q?uQ1pNSG+xOYbTJYhE8TaDEZe7dVVr8P5Y16J6ElPMSVIGytu3qIdF93u?=
 =?Windows-1252?Q?x/FF0C024v1w2Vl5AAmUH3UziVrSWyCRBYzG/OJNFaKOoG0leNQO86wX?=
 =?Windows-1252?Q?CB+wFZCuS3/vpGTcTvoBmHPOpL+sTCjDyTQzcZhnSW15uchjwFoYkYMA?=
 =?Windows-1252?Q?UE7L9EFewjEik+cGnBCgCpkbQRanUx27HyZi+TZhed4YB5qH7EyUeE8Y?=
 =?Windows-1252?Q?N+FxIVbs7moyU0sOTYm6HgqelmolxcbhLytb2/JF3gBGibAaZaUBK6c0?=
 =?Windows-1252?Q?DxKbWzw9Nzlr/5AXcnFYzen+RI0ICzWNckuOzmmFa2WOGGralVsIZ5WM?=
 =?Windows-1252?Q?aRQIrZdNm44cRdrXVUOQGcx6VE6pyF0ZR/VnNaxOrQp/g+1e/J0uXP5c?=
 =?Windows-1252?Q?F4b1gphXGE0SchIzu9vO5j/PNzFpx2fe+RF2/LfsVOyjD7Znapqu9FA2?=
 =?Windows-1252?Q?24tveNBmcigQlCWQg/w+BZCnY8kv8eNvPr8aj5JOcPeqidI0rUVyVnKT?=
 =?Windows-1252?Q?Zsw9HR5E7EnLUj+w602hOT4KdzI/KXq38v0B1uzDde6b8hGrJ0qFytoO?=
 =?Windows-1252?Q?uEgDesz/Cm9LnkSwYrwzikKRed92p4+PEKEE6kewYNuZT1IJW3zuXDIj?=
 =?Windows-1252?Q?IcyemCKvgVMdjHRau+cdJHoU/5eM5apKI3mLZf26ZMXUfT62l64ZS20n?=
 =?Windows-1252?Q?YkdA2yPsRvPGZUaGd787U3GGUy+Nc8DvuqZQmzLXITCJZIxAOF5vI1ZT?=
 =?Windows-1252?Q?IwOJzhucOUfBEHD3Ggm5M7l5eQmKD/05WZK9JB3RCVbVkdI710ScjF/J?=
 =?Windows-1252?Q?QFLg4Li6Yo74zX44y3+ChOX7aC27u580K1SZreHlXcrHRhRdG49vTANH?=
 =?Windows-1252?Q?be56fVPGXJQdEr/WAPcYvMosfBIJVLIjfegQ5S+jBcLGiqoSyITscL/s?=
 =?Windows-1252?Q?iJzueYJprBR52IIIPH2nwWrZe7W5vocbzVlk4gDjkPS4RMkKhvd6tWH/?=
 =?Windows-1252?Q?4MpzXl/lxDgaRKx1ECoMAZqiey6XkGRveUl9vNf1z0Pzmo4bDgi18c9L?=
 =?Windows-1252?Q?YvP6PyncgjkfikMfRt/WP4WrSY9ELVjIvITdFEe8HQZWIS1On5OWWY7l?=
 =?Windows-1252?Q?SX4C9S+vIwqHKI1gqvmv8GzL7WVi5bhT2QWveca9el9lPoiW0R3vgj6c?=
 =?Windows-1252?Q?sz/SwLZjV1d03KGjlI0pVUwkgbzNPLk9pqVhmlgiHQ/dBtlm9IdzVVc5?=
 =?Windows-1252?Q?dr+IhUp7r6UWwFTRIkLaKpvAV5i7qr/jzW3wPGj3Zg4MLEiMPz2u4RyF?=
 =?Windows-1252?Q?/Wg1SyIovhbJVo1IWxhNfNXV7qtOJC1MtXNSnv7Buv+wzCZbGBcRF30y?=
 =?Windows-1252?Q?wwqw88XponGPQ7apTPOX7AGjieB/DOfyz8gYiqur/Izu1/RGqpc=3D?=
x-forefront-antispam-report: CIP:255.255.255.255; CTRY:; LANG:en; SCL:1; SRV:;
 IPV:NLI; SFV:NSPM; H:DM6PR19MB2636.namprd19.prod.outlook.com; PTR:; CAT:NONE;
 SFS:(13230040)(376014)(1800799024)(366016)(13003099007)(8096899003)(7053199007)(38070700018);
 DIR:OUT; SFP:1102; 
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0: =?Windows-1252?Q?D4cOMnM2/DXgD/V7wFiEkiUTEgPjhpqiWyC0VahvnYBnqAp6wxD+zvcI?=
 =?Windows-1252?Q?EVA3e+Jj1jrgYVIYJ7yXP5gp6tNTdFoiW1UkJEhTpMF6F+pLt+U9R/Js?=
 =?Windows-1252?Q?+ud1Aj2r6Pr7b/jN2O73W279nEU7KtXIBzsmIcR3SpIwgFllt0/DdRWz?=
 =?Windows-1252?Q?MMoKWbg9im3yXthwdDbShfCl88LqjNRf78LCom65sxJXI1vXR71J3OwI?=
 =?Windows-1252?Q?J68qmc2OrhMKYAj0jbwrL4JJcF5pevPxpRB0/iH7JgxbcfLMtDLyo/Ku?=
 =?Windows-1252?Q?enwyHaNoVhYGYyDXbAK4hseON0Kono93Il3TYQLSrdJo5W3x47YGXPsr?=
 =?Windows-1252?Q?dy09SsmtAIO/9lD31H2+JtNCeqI9Kw9F+rvP7EgX27FNX9hfGsSZpk1N?=
 =?Windows-1252?Q?iQ2MQ8yeqD005SfgM5ar5uWHn5SJ002jrfdzVyAh7K/6vcKqkBx7O2eL?=
 =?Windows-1252?Q?VNCxw3FOgwcnOdIqjzEGHA/mgBdRWJTyiA91g62syvlWns0Lkrerh0wE?=
 =?Windows-1252?Q?lpcqAuHHLcqxCAu4z0KMmMw076CEAk6pzTXPchZeQXusM2YZfLS8QC/e?=
 =?Windows-1252?Q?7z8kXmp9qtSxCDcacb5WNXxUmBCT4hQjUDDYlQgXFHdsl1sneNBZ59zZ?=
 =?Windows-1252?Q?j3bVEugHZAMuYfR/FPN1sRtd3HmbHcmyKWv6jY7PUvvLvKSq5qgeRC0T?=
 =?Windows-1252?Q?BQr9Muxpuyeic91J/nvL+saFI3a1fF1tIL7xSdJV9Uhi6LWD9L+RuX85?=
 =?Windows-1252?Q?o3utCkkbZNmXBToD8dVmhe94LAkhVFMMsuJUuMuwdg9pdnqGkaYJJwpE?=
 =?Windows-1252?Q?P0Bo0NSZlk5wCme/JDl0xDCbFzMtxUoG280Ki75c9WTQanf8Lya6jBhv?=
 =?Windows-1252?Q?X/OKJaWLZclq3pFAXllMQN/xiO7xKesO38p4+0FxtB9an8QH/22Nmnzd?=
 =?Windows-1252?Q?VC6w+wY3zU3YMpwjzc+o2BBF6W8v+P+IeflYFTAqcnCByzqjB18bxsb4?=
 =?Windows-1252?Q?9SlmDKAWN6nD0aOLicZUpmtwedPwb4egnppNA0ESYy2X+3XapiunUhKC?=
 =?Windows-1252?Q?6ePxCQnJli+M92ACEdbhjYc8TBeqrxwKgs6cmnAwN6SBXMQzeErv238l?=
 =?Windows-1252?Q?TWVJPvJxvvEYgIfZVz2x75o2aoG023JNVrfIVHkPMMVKjJP+BH6bKrvr?=
 =?Windows-1252?Q?vP5Qch8QSqYTOwEZINjhEIgEB3e+J5puhcWB1hVuW47Nc1n/mGj3HHhg?=
 =?Windows-1252?Q?KBScJQU+8OpOYrOMdAx47TbkRTE7IJJApSIDnAVe7rI/BGpXxPja4HGc?=
 =?Windows-1252?Q?0t4T9vWf+PSsXGEs1nxtoe/vsvxzvmUG2CMmvCo7VaoJTdUvmv9sIO0t?=
 =?Windows-1252?Q?gFUn+XkCkah92BJmhDl2RZChCxn0ZCJDS2jfvu3yuJhkUORSn/Iw+Des?=
 =?Windows-1252?Q?5VFSq+F3LsXnehxC1MfaeH+g/2q5Exvq57x7fk8Il1qcMgufiAag+QXe?=
 =?Windows-1252?Q?yoiL8jWv2rTmGEnQRuZ4USpTGv9WXqYS4LzQd6dZWniXhf1RdJhPy10Y?=
 =?Windows-1252?Q?nRIXHOmidVIq0HmrtVDSR4bzsiRqH/q+CVl6wcofM7GFA7+cutV7NZTa?=
 =?Windows-1252?Q?N1h7b072qgkPrAZHP6Pa8KZMbyl912w+bfKudmbxKRLGRRGc4LnVeEcK?=
 =?Windows-1252?Q?UvG4RNyv8LA=3D?=
MIME-Version: 1.0
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-0: FRGHW7pEghpEBZFhDtwc5eX6/LrxB4qigyQFP4GghGyY31z1rlaagF3439DQ3QhjGB0vXIeaLMw9H7I3jmAz1o28D+FmwJF8shr7X6G1/Mwby0/lTcBlQO2YsrgvExgnqP/5Fskb7yEFrXPk/30S0NMlEPdkd65q5+EmWpqgAHQKWX3KtyR/UQ/UBD7FVgMwoJ7bdQP4ENTic1G9VfKfo++04U2m1/QrLrkH3Ry4ymunWhcCbD8w0sqET3GSX9HaL4+N9o1gdzSMsXp6FME83Hpf3vUN5lZch7ruxkIPh70X3eni8ysyFOZ9qN5k0ulHYdpIDStVjq5TfZtF4OrRB+q7J7evMU6b/huR9AtnBAzd2unrRa2q4xKgKZP53oI62tYu5kydJk3kNH0bmmCHLtPK5KXpal1up84N8TbEIlH3/JpJek9TMbxIHObukGKYd9CpDb99i1mJ+/EqvDh2AGY1zPdGDbEoWAo4nH6CdU9BT25JoEfUUFGNvQ0gJkiKbwvYUYq+3LV5qV4uYefPIrR8IwvBlDZ6kRf2KKihlhw81n/gm7VYUfxe7iH80BolySvM0ZT4l9Gpv7ti+Zk/EtwWL2G7Cb9qZlcvuPETmkM2KbyLVJd3p8ad/hv3/2Nuzop8BjP1gNHggW0FpKMftA==
X-OriginatorOrg: ddn.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: DM6PR19MB2636.namprd19.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 9bd62255-3a1f-44a1-c6f0-08dd872a6f4c
X-MS-Exchange-CrossTenant-originalarrivaltime: 29 Apr 2025 14:30:48.1640 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 753b6e26-6fd3-43e6-8248-3f1735d59bb4
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: MGqWbMkSQaW2ttRGb0eZ7K0bG5gq5xcOpXmKYFwrboBm/y0s1tlezHDH+EAi4m4nue+CFOqWnpcHxUJVpHTmvg==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SA6PR19MB8673
X-BESS-ID: 1745937052-102281-7696-17081-1
X-BESS-VER: 2019.1_20250422.2023
X-BESS-Apparent-Source-IP: 104.47.55.169
X-BESS-Parts: H4sIAAAAAAACAzXLOw6EMAxF0b24poA4jjFbQVP4Q0SDKCbFSIi9Twponq6edN
 YLtl+DBVrfAc4vLJNk6bX3k6RqKh7BzhoSMQkjmVV1RfMR7uH1ezsej8z0eEcTc5ecsi
 cNonlkL2oZa5HEFe7PHwdBgPyBAAAA
X-BESS-Outbound-Spam-Score: 0.01
X-BESS-Outbound-Spam-Report: Code version 3.2,
 rules version 3.2.2.264235 [from 
 cloudscan18-232.us-east-2b.ess.aws.cudaops.com]
 Rule breakdown below
 pts rule name              description
 ---- ---------------------- --------------------------------
 0.01 BSF_SC0_SA_TO_FROM_DOMAIN_MATCH META: Sender Domain Matches Recipient
 Domain 
 0.00 HTML_MESSAGE           BODY: HTML included in message 
 0.00 BSF_BESS_OUTBOUND      META: BESS Outbound 
X-BESS-Outbound-Spam-Status: SCORE=0.01 using account:ESS124931 scores of
 KILL_LEVEL=7.0 tests=BSF_SC0_SA_TO_FROM_DOMAIN_MATCH, HTML_MESSAGE,
 BSF_BESS_OUTBOUND
X-BESS-BRTS-Status: 1
Subject: Re: [lustre-devel] [lustre-discuss] Beginner: Lustre server compile
 and deploy
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.39
Precedence: list
List-Id: "For discussing Lustre software development."
 <lustre-devel-lustre.org>
List-Unsubscribe: <http://lists.lustre.org/options.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=unsubscribe>
List-Archive: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/>
List-Post: <mailto:lustre-devel@lists.lustre.org>
List-Help: <mailto:lustre-devel-request@lists.lustre.org?subject=help>
List-Subscribe: <http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=subscribe>
Content-Type: multipart/mixed; boundary="===============5242059597334940792=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============5242059597334940792==
Content-Language: en-US
Content-Type: multipart/alternative;
	boundary="_000_DM6PR19MB26366C743933C2132E4BDBA1C9802DM6PR19MB2636namp_"

--_000_DM6PR19MB26366C743933C2132E4BDBA1C9802DM6PR19MB2636namp_
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: quoted-printable

Note you can use Rocky or Alma Linux instead of RHEL.

There are links to current instructions here:
https://wiki.whamcloud.com/plugins/servlet/mobile?contentId=3D9536415#conte=
nt/view/9536415



________________________________
From: lustre-devel <lustre-devel-bounces@lists.lustre.org> on behalf of And=
reas Dilger <adilger@ddn.com>
Sent: Monday, April 28, 2025 7:06 PM
To: GEORGE ZHAO <georgezhaojobs@gmail.com>
Cc: lustre-discuss@lists.lustre.org <lustre-discuss@lists.lustre.org>; lust=
re-devel@lists.lustre.org <lustre-devel@lists.lustre.org>
Subject: Re: [lustre-devel] [lustre-discuss] Beginner: Lustre server compil=
e and deploy

On Apr 28, 2025, at 09:14, GEORGE ZHAO via lustre-discuss <lustre-discuss@l=
ists.lustre.org> wrote:

Hi Guys,

I'm a beginner of Lustre and kernel development. Spend weeks to figure out =
how to build Lustre server from source code. But reach nowhere.

The wiki is for RHEL7, which is too old. Although, RHEL subscription is exp=
ensive.

Maybe Ubuntu is a better choice for me? There is a confluence page for buil=
ding with ldiskfs, not zfs. Maybe zfs is simpler? I'm not sure.

My goal is being able to contribute to Lustre, so I need to build from sour=
ce code. Official RPMs doesn't matches AWS AMI kernel version, that's an ot=
her reason.

The TL;DR to make Lustre server code is the same as the client, regardless =
of the kernel distro:

bash autogen
./configure
make (or "make rpms")

the important caveat is that you need the source code for fs/ext4/.  If you=
 download and install a pre-built kernel (including .src.rpm and kernel-deb=
ug) for your distro from https://build.whamcloud.com/<http://build.whamclou=
d.com/> then you don't need to worry about that step.  Patching the kernel =
is not strictly required for server kernels (either ldiskfs or ZFS), but wi=
th ldiskfs you need to have patch series that matches the in-kernel ext4 co=
de.

Cheers, Andreas
=97
Andreas Dilger
Lustre Principal Architect
Whamcloud/DDN





--_000_DM6PR19MB26366C743933C2132E4BDBA1C9802DM6PR19MB2636namp_
Content-Type: text/html; charset="Windows-1252"
Content-Transfer-Encoding: quoted-printable

<html>
<head>
<meta http-equiv=3D"Content-Type" content=3D"text/html; charset=3DWindows-1=
252">
</head>
<body>
<div>Note you can use Rocky or Alma Linux instead of RHEL.</div>
<div><br>
</div>
<div>There are links to current instructions here:</div>
<div><a href=3D"https://wiki.whamcloud.com/plugins/servlet/mobile?contentId=
=3D9536415#content/view/9536415" data-ogsc=3D"" style=3D"">https://wiki.wha=
mcloud.com/plugins/servlet/mobile?contentId=3D9536415#content/view/9536415<=
/a><br>
</div>
<div><br>
</div>
<br>
<div></div>
<br>
<hr style=3D"display:inline-block;width:98%" tabindex=3D"-1">
<div id=3D"divRplyFwdMsg" dir=3D"ltr"><font face=3D"Calibri, sans-serif" st=
yle=3D"font-size: 11pt;" color=3D"#000000" data-ogsc=3D""><b>From:</b> lust=
re-devel &lt;lustre-devel-bounces@lists.lustre.org&gt; on behalf of Andreas=
 Dilger &lt;adilger@ddn.com&gt;<br>
<b>Sent:</b> Monday, April 28, 2025 7:06 PM<br>
<b>To:</b> GEORGE ZHAO &lt;georgezhaojobs@gmail.com&gt;<br>
<b>Cc:</b> lustre-discuss@lists.lustre.org &lt;lustre-discuss@lists.lustre.=
org&gt;; lustre-devel@lists.lustre.org &lt;lustre-devel@lists.lustre.org&gt=
;<br>
<b>Subject:</b> Re: [lustre-devel] [lustre-discuss] Beginner: Lustre server=
 compile and deploy</font>
<div>&nbsp;</div>
</div>
<div style=3D"line-break:after-white-space">On Apr 28, 2025, at 09:14, GEOR=
GE ZHAO via lustre-discuss &lt;lustre-discuss@lists.lustre.org&gt; wrote:<b=
r>
<div>
<blockquote type=3D"cite"><br class=3D"x_Apple-interchange-newline">
<div>
<div dir=3D"auto">Hi Guys,
<div dir=3D"auto"><br>
</div>
<div dir=3D"auto">I'm a beginner of Lustre and kernel development. Spend we=
eks to figure out how to build Lustre server from source code. But reach no=
where.</div>
<div dir=3D"auto"><br>
</div>
<div dir=3D"auto">The wiki is for RHEL7, which is too old. Although, RHEL s=
ubscription is expensive.</div>
<div dir=3D"auto"><br>
</div>
<div dir=3D"auto">Maybe Ubuntu is a better choice for me? There is a conflu=
ence page for building with ldiskfs, not zfs. Maybe zfs is simpler? I'm not=
 sure.</div>
<div dir=3D"auto"><br>
</div>
<div dir=3D"auto">My goal is being able to contribute to Lustre, so I need =
to build from source code. Official RPMs doesn't matches AWS AMI kernel ver=
sion, that's an other reason.</div>
</div>
</div>
</blockquote>
<br>
</div>
<div>The TL;DR to make Lustre server code is the same as the client, regard=
less of the kernel distro:</div>
<div><br>
</div>
<div>bash autogen</div>
<div>./configure</div>
<div>make (or &quot;make rpms&quot;)</div>
<div><br>
</div>
<div>the important caveat is that you need the source code for fs/ext4/. &n=
bsp;If you download and install a pre-built kernel (including .src.rpm and =
kernel-debug) for your distro from&nbsp;<a href=3D"http://build.whamcloud.c=
om/" data-auth=3D"NotApplicable" data-ogsc=3D"" style=3D"">https://build.wh=
amcloud.com/</a>&nbsp;then
 you don't need to worry about that step. &nbsp;Patching the kernel is not =
strictly required for server kernels (either ldiskfs or ZFS), but with ldis=
kfs you need to have patch series that matches the in-kernel ext4 code.</di=
v>
<div><br>
</div>
<div>
<div dir=3D"auto" style=3D"letter-spacing: normal; text-align: start; text-=
indent: 0px; text-transform: none; white-space: normal; word-spacing: 0px; =
text-decoration: none; line-break: after-white-space; color: rgb(0, 0, 0);"=
>
<div dir=3D"auto" style=3D"letter-spacing: normal; text-align: start; text-=
indent: 0px; text-transform: none; white-space: normal; word-spacing: 0px; =
text-decoration: none; line-break: after-white-space; color: rgb(0, 0, 0);"=
>
<div>Cheers, Andreas</div>
<div>=97</div>
<div>Andreas Dilger</div>
<div>Lustre Principal Architect</div>
<div>Whamcloud/DDN</div>
</div>
<br class=3D"x_Apple-interchange-newline">
</div>
<br class=3D"x_Apple-interchange-newline">
<br class=3D"x_Apple-interchange-newline">
</div>
<br>
</div>
</body>
</html>

--_000_DM6PR19MB26366C743933C2132E4BDBA1C9802DM6PR19MB2636namp_--

--===============5242059597334940792==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============5242059597334940792==--
