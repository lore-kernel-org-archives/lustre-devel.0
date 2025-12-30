Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id AB80BE9410F
	for <lustre-devel@archiver.kernel.org>; Tue, 30 Dec 2025 05:54:21 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4dgMYN6WVjz20jq;
	Mon, 29 Dec 2025 21:47:20 -0800 (PST)
Received: from CY3PR05CU001.outbound.protection.outlook.com
 (mail-westcentralusazon11023077.outbound.protection.outlook.com
 [40.93.201.77])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange ECDHE (secp384r1) server-signature RSA-PSS (2048 bits)
 server-digest SHA256) (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4dgMTq3pBcz1xPq; Mon, 29 Dec 2025 21:44:15 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=c8RMqBGzINtDkgt/GpkLeFpDULyR1+Ml+tOPMf8kY4SXpyiy/QNma0Dsj6WlwHBR8XREbsq2QpqJcP+C94m1HEhp6i3FGBzZFSJt82ZWTtv6tzFoLiE7aHJsWPWYX6rd2PSSxYEfaJB8ZJyGsOJEt1+/SGYkL9EPk/W+vCcbz2rEpNWviVhJdZBwjp08a2sHFcHJnPixe1OkD6b5pozKEtP07nAwsDY8Omk2LO11lNCeqDg+i0NJt7cWgCvHu5hZqi8M+53/KDpc8y1GfnxuHO/JnGZW25cONeAyVe2ioB3b75jWKOiaEv3qdXgKkuwI/uuPkWzzujopjhAoKufR0Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com; 
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=wbxzITOMZRnHE1SNYM0CinWeQMIslpQuo3sUVydcyok=;
 b=CLbi2h0z7KJYnz5t3wVI/6nRyHBghQU1oupySLjb3xYisGjTcrrl/TWQ3bF5p3DNRB+XGwvJVbtAoYMjHaWuybunGxL/KTBmn/ChuHJHxGzWnv/WKr2eyxty6LcXHUxI5kZxQWRH9REUmLvJ2ySiCH9QAItCBTEODeG6stLzWXjSmVc2EQNW00VKo0KqCPqnxT2mVco0tqRFSXYAELqk1KpdfsWwOk9qOF7kRrw7WkmcSOyaZevgnm6nrUGnoX+i+Ng8ebNidRSI09xCHbjGT+HqApYodwsMK5W8+nuJGawooZ1vvA9O0lDIWiC/kue+ZiNMM1BEQWFb0QYrUi6VlA==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=thelustrecollective.com; dmarc=pass action=none
 header.from=thelustrecollective.com; dkim=pass
 header.d=thelustrecollective.com; arc=none
Received: from DM5PR0401MB3526.namprd04.prod.outlook.com (2603:10b6:4:78::18)
 by CO6PR04MB7636.namprd04.prod.outlook.com (2603:10b6:303:b2::8) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.9456.14; Tue, 30 Dec
 2025 05:44:12 +0000
Received: from DM5PR0401MB3526.namprd04.prod.outlook.com
 ([fe80::4435:7a21:c298:7ddd]) by DM5PR0401MB3526.namprd04.prod.outlook.com
 ([fe80::4435:7a21:c298:7ddd%4]) with mapi id 15.20.9434.009; Tue, 30 Dec 2025
 05:44:12 +0000
To: "lustre-announce@lists.lustre.org" <lustre-announce@lists.lustre.org>,
 lustre-discuss <lustre-discuss@lists.lustre.org>,
 "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>,
 "lwg@lists.opensfs.org" <lwg@lists.opensfs.org>
Thread-Topic: Lustre 2.17.0 released
Thread-Index: AQHcad5zEkIpEHTckUSY4rwPe3WBtg==
Date: Tue, 30 Dec 2025 05:44:11 +0000
Message-ID: <CH2PR04MB69667BACADFDD0527A4BBDB2CCA0A@CH2PR04MB6966.namprd04.prod.outlook.com>
Accept-Language: en-CA, en-US
Content-Language: en-CA
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-ms-reactions: allow
authentication-results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=thelustrecollective.com;
x-ms-publictraffictype: Email
x-ms-traffictypediagnostic: DM5PR0401MB3526:EE_|CO6PR04MB7636:EE_
x-ms-office365-filtering-correlation-id: 604e73bf-ef6c-44c9-718b-08de4766760b
x-ms-exchange-senderadcheck: 1
x-ms-exchange-antispam-relay: 0
x-microsoft-antispam: BCL:0;
 ARA:13230040|34096008|376014|366016|1800799024|10070799003|38070700021|8096899003;
x-microsoft-antispam-message-info: =?us-ascii?Q?O6qyCoFBKBrbDYqCkSGW73iUXK5Ge07427GjQ+kYQxHPyRFb9euXHipy1WxY?=
 =?us-ascii?Q?A+bLZrALbclE7YYEXePwOq00rhAJd77p6YBN2KkoFPhNPPeCFjzFndCd153Y?=
 =?us-ascii?Q?4uegHttTuJwQuQ6wQ9p8cvfuTi+J3bAzYef1E9xKlfz0ha0X2GVVXRSzzsAk?=
 =?us-ascii?Q?hMVCTPtvPOaVPkWvnuolwM/5HvPX3E9vRDa5JM3f8D4UA5xJTKHmzVif9B5j?=
 =?us-ascii?Q?Rflym0ttuuGj6S+K3axCxQuAjm+QxuK11AMTJyhU0HZp3SWWMDtd7HdjkguM?=
 =?us-ascii?Q?xzGj14O2ctiGRnRUb5LfYUht6082mHJX+wP/qicrkFyPsfy23osrXId/LDJ7?=
 =?us-ascii?Q?EAF8P7P6tfUX9CqcxC3qpBzReNeMacUzHrmUDF0vPq9PYyzFCpUQVncL0kb3?=
 =?us-ascii?Q?bwoejo1zN8ZHNUJR3ms1DJ5S0R5QU6KinZiPYOezD4vPro3wLshBaGNty+dC?=
 =?us-ascii?Q?uPA+YJ8vaFxZXH5JKlCRFKTBRb9gODQy8qYFz9B6zrTYjAxaYpd21KLiOnIq?=
 =?us-ascii?Q?ApA/mA8RGrHENzjYUEwu9g0P5+oCe+oDZzKHJl9Tka7WJA6bfaZgJfPg9vnU?=
 =?us-ascii?Q?5CYfnFfx5Gsa/rRFL+DaPlMbuNCKKxumwMSE3I9s5hfPYUrLdTnDwth1LLl0?=
 =?us-ascii?Q?pSiq1+RPGtOllR4DgXDNiKZX3aZm+v/RBXoEykzzxSDAxE0b5GczEVS0fGym?=
 =?us-ascii?Q?6479n8AksKrZsVj488EpDhInR0n6YHuRGcye17r/sLzMakKwMV6gZ9bc9eTP?=
 =?us-ascii?Q?bDxSJ0vNrKc8wR17mykQluqL4eZC3xHwZrN/EC0MNMVChacjTYvQX5q3emRT?=
 =?us-ascii?Q?UISHDwnKvHtdM+Y2/rMCpLkVDsNzmXOoqv1EsHz4Q5EofgxPlmLg3sCvvwH7?=
 =?us-ascii?Q?4D2AHPeUF6Ctr7+NlEpBplJnMekpxip+yQcA7/HwJTs5SYN0sr4XllZkiioJ?=
 =?us-ascii?Q?ZhYnfaPZcpiYzpoIDkfdo7s/RiQDHkoZn5E5LAtMb4aNKgRi7iecwlSl3bZ5?=
 =?us-ascii?Q?VKe3xhTppbLqbsjRXuU0Y89p8lGbLjGDQw73WdlOG7ZG1P4/0Ai9guBfw9ds?=
 =?us-ascii?Q?7BUyniwtFY0KbW5RGgypTLCWoTpLWaj7HGHScunYGAWmuqElCp7ROlajpu1Z?=
 =?us-ascii?Q?HUNfnhXA+Fq7WHQ0B2tlo2LjpILD2AFU0aA5/5o3gEeEufSgwLzh37hCWG1I?=
 =?us-ascii?Q?9gKPy5DEeZyz3VvqrOLkq2oXZJ5LEJ3/bfOXp38pSH2SaK5r1Xn6aOx1Gw/Q?=
 =?us-ascii?Q?WmyESDMBXFF4sVlQt/HGVSraMLi5VNe20wbvWpmaDu4UFFb514DdOoTpsmU8?=
 =?us-ascii?Q?STr7lh53ogBlHfl2g1fRlK4M61i6rrUiciYuyziiHUzQevD9G4Jf+E6asuSu?=
 =?us-ascii?Q?+F62HO8cTG4bRbdCBYg7PjAoHIc22tr3okyE+wV5z7CrpcH2cIyxgsqHTF5L?=
 =?us-ascii?Q?gYoYqNH7NpJhQ3JXmzfCx/Crf1I7bMBFw2LNUzlWYofnJOjMtT1jVA=3D=3D?=
x-forefront-antispam-report: CIP:255.255.255.255; CTRY:; LANG:en; SCL:1; SRV:;
 IPV:NLI; SFV:NSPM; H:DM5PR0401MB3526.namprd04.prod.outlook.com; PTR:; CAT:NONE;
 SFS:(13230040)(34096008)(376014)(366016)(1800799024)(10070799003)(38070700021)(8096899003);
 DIR:OUT; SFP:1102; 
x-ms-exchange-antispam-messagedata-chunkcount: 2
x-ms-exchange-antispam-messagedata-0: =?us-ascii?Q?FMd9Yg4mjh+mHZLPBbSB3MZ1hF/bSwvDlqeODD4mACP/KEOAtptt8Y/Z/KHf?=
 =?us-ascii?Q?KtTXd3wORQrbmWjEkpmK0mZ3etE0pRzYrSCY9YQy97gCp1zH28ZEIDBwM1RF?=
 =?us-ascii?Q?fNXt6vKYl4oP7OJOOjeigVDkiOej3nOf5EAzq+bqpU7CNQugYj0RMFRiBHX8?=
 =?us-ascii?Q?31z8qcZHUl42m38Wc/8LeCtGsTCvYL3UghVljKWrCfsHS/utaakpa+Pz/wi2?=
 =?us-ascii?Q?I1jTAIOTNHAkae10psucG+DS//B7ryzWAp00alaZBmfd3nQ5e5PJLJv/GS+P?=
 =?us-ascii?Q?0YpL1TZmW/GRikyUsjwCkd9WSLPVLOk0Gz1A0r/i59YLxlSN6p19k7apUPx7?=
 =?us-ascii?Q?ud4/uuAFBXUgyBZWtoeYUIiGESXnj7lG3s7jI8taWhkYtZaTVfr6rY5YBi7x?=
 =?us-ascii?Q?KaSMNOkBDECa+md9rzimqH9ffZfE0z3Hay0uS1cvflsD6xIKC2SDQX+EIqKu?=
 =?us-ascii?Q?FyJgPkQg/11fw8Hu34/LWMFpCgfyBfWEfZlTnXTEeCEnhh+2c0PX8QNNb6e8?=
 =?us-ascii?Q?t8QO+VVKmqrU/gdbg226dsi6c8Nq465479PaF4Orx2w+/fiPdXK7qzR4zTMW?=
 =?us-ascii?Q?Pip0y6i7cEUSRtsTzOWpmv8yLIsXtmxxiFq1vd3TfbB/ZrsiDbNuzv7HbX11?=
 =?us-ascii?Q?cKqBditDbomJ2Xu4HG6PRqzClgxrUZNfCW6Iz1QkZ7eWSRgZPXCEpCKk/M7I?=
 =?us-ascii?Q?3cg4RqjZ9gu2jq6TpTjPRVGgsnfOzTOFuSTPJ4rF4y5twc/CPzZtmqWfPET6?=
 =?us-ascii?Q?XPE83tjn7L2Gr4nfxxLYQuyhGuCk4cK3ZK62hmuyE2G5hKkRMVu6IJqOo2dL?=
 =?us-ascii?Q?++ywjshgP8FymG5g3caHwjV+Uh0fnAQ1MPPDjtUDjg4UrKE1/Pomh1ulwKne?=
 =?us-ascii?Q?EWDRhsiZ40DFC3u/n3dIxGoViaAdcbDZ3UIv7HNsUzkBakbLOvrBiuboEPwm?=
 =?us-ascii?Q?twYrHz7cs5vuQlI9HkYRp2WETMWavdoIXO9dG/QiOZtx+N/n+yOE2WWoaJyf?=
 =?us-ascii?Q?xMHCkdHEXw/xtDeNckltNefip5x2cHXHJr2WRaurmwetJPhg8m3tXfz+37Qs?=
 =?us-ascii?Q?aTU6rwz0NxVld597vGM9WwJrK88YOhnejspR4NuFh0o5P2M/HpyCjkm/y40O?=
 =?us-ascii?Q?g2ZMnKgJK/uKF8tvj2wfoD3T75Px6TA++R6MAtVP5QEp4EabzRJjc+r++NlB?=
 =?us-ascii?Q?10YGr9owJuVZt+SuWV6wKkb3bk8HPhVMCDBqQ6o/DFhhv9m32RXecLWBxUig?=
 =?us-ascii?Q?1c8j6phC+lenQljb+ovQOr6i1DLoNOSvyHkOGHyKOtJ4NKSvOppp6Gm9+T8A?=
 =?us-ascii?Q?lEw11odeYFrz3XjLZ5vpW1nSsWePKRGRUnWeBKqQuJIM2y6O3Reo5gf9WOnF?=
 =?us-ascii?Q?TnXIvgg9C4T4JNzUduHu7GJaG8vzziokLNPQtXMkfVk12U3GJ2PbX7Vs1NmK?=
 =?us-ascii?Q?T7V5TYECWeBFoO1pPpWZpFRArGvgwBjq+N9rVD/d6xpLiHNyTmQXPZSj4xI2?=
 =?us-ascii?Q?bLOD69/Hr2sZUqT88ffUZh9Ml9yJu2fCy7i/o6Ko3/0B+gomz16yXAcAwcut?=
 =?us-ascii?Q?7DAFe7O1LhYtgk2XfOnFxVKsZ6PkEfCwt++1GOfVZmERfYwpLAIEtLlsha9q?=
 =?us-ascii?Q?JLPm2z3Fg4nvILyd0b7yt2ouxFvHJQviVCaFrkdzl1TGScNFOG10IV8sHXvs?=
 =?us-ascii?Q?2bxNGdS372QpApdmHI+BTKTzj+gg2FHuAHkMcbkYoD15vwERLw2i9GzkA9yT?=
 =?us-ascii?Q?L5s7zgqRwCQETNsDcMWIr4ryYDfTX+j6iZZwXZf8AuuBNd7WPDdIJtM8GzKj?=
x-ms-exchange-antispam-messagedata-1: EukOQ35aS0gu7Ti2k1eN4YpVeV/X6MjbmdgNouOwUw1Hu7yGwfvVPIC3
MIME-Version: 1.0
X-OriginatorOrg: thelustrecollective.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: DM5PR0401MB3526.namprd04.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 604e73bf-ef6c-44c9-718b-08de4766760b
X-MS-Exchange-CrossTenant-originalarrivaltime: 30 Dec 2025 05:44:12.5657 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 4c9dec06-8f2c-4233-98d5-ca3cb36218fc
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: zF1OF2jnjvlnXcauGenjHLw1qef4g9G7/3kALfEJya5oaBvOMoefCqCuTpRhJvjTh9R5lBZEbXSuZDUxtLno1KuJXYGF6gYR6UKibOQ59/s=
X-MS-Exchange-Transport-CrossTenantHeadersStamped: CO6PR04MB7636
Subject: [lustre-devel] Lustre 2.17.0 released
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
From: Peter Jones via lustre-devel <lustre-devel@lists.lustre.org>
Reply-To: Peter Jones <pjones@thelustrecollective.com>
Content-Type: multipart/mixed; boundary="===============1620865274803462158=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============1620865274803462158==
Content-Language: en-CA
Content-Type: multipart/alternative;
	boundary="_000_CH2PR04MB69667BACADFDD0527A4BBDB2CCA0ACH2PR04MB6966namp_"

--_000_CH2PR04MB69667BACADFDD0527A4BBDB2CCA0ACH2PR04MB6966namp_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

We are pleased to announce that the Lustre 2.17.0 Release has been declared=
 GA and is available for download<https://downloads.whamcloud.com/public/lu=
stre/lustre-2.17.0>. You can also grab the source from git<https://git.wham=
cloud.com/?p=3Dfs/lustre-release.git;a=3Dcommit;h=3D4b0407a48e9e5b7f17877e8=
868080e9f40c238c6>.

This major release includes new features:

Hybrid IO Automatic performance optimization for large IO (LU-18033<https:/=
/jira.whamcloud.com/browse/LU-18033>)

Dynamic LNet NID Configuration Improved online configuration of LNet interf=
aces (LU-18815<https://jira.whamcloud.com/browse/LU-18815>)

Nodemap Enhancements Dynamic Nodemaps to support more sophisticated multi-t=
enancy options  (LU-17431<https://jira.whamcloud.com/browse/LU-17431>)

Fuller details about this release can be found in the 2.17 wiki page<https:=
//wiki.lustre.org/Release_2.17.0> (including the change log<https://wiki.lu=
stre.org/Lustre_2.17.0_Changelog> and test matrix<https://wiki.lustre.org/R=
elease_2.17.0#Test_Matrix>)

Please log any issues found in the issue tracking system<https://jira.whamc=
loud.com/>

Thanks to all those who have contributed to the creation of this release.

This release is dedicated to the memory of Frank Sehr who was a member of t=
he LNet development team. Frank passed away suddenly this summer and is mis=
sed by both the Lustre developers and the customers of the Surf Lodge Pub<h=
ttps://www.surflodgegabriola.com> where he regularly played music.





--_000_CH2PR04MB69667BACADFDD0527A4BBDB2CCA0ACH2PR04MB6966namp_
Content-Type: text/html; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

<html>
<head>
<meta http-equiv=3D"Content-Type" content=3D"text/html; charset=3Dus-ascii"=
>
</head>
<body>
<pre style=3D"background-color: rgb(255, 255, 255);"><div style=3D"text-ali=
gn: left; text-indent: 0px; white-space: pre-wrap; font-size: 12pt; color: =
rgb(0, 0, 0);">We are pleased to announce that the Lustre 2.17.0 Release ha=
s been declared GA and is available for <a href=3D"https://downloads.whamcl=
oud.com/public/lustre/lustre-2.17.0" data-outlook-id=3D"4938bfba-82f8-44ee-=
8a1b-2bfad4aa66f4">download</a>. You can also grab the source from <span st=
yle=3D"background-color: rgb(255, 255, 255);"><a href=3D"https://git.whamcl=
oud.com/?p=3Dfs/lustre-release.git;a=3Dcommit;h=3D4b0407a48e9e5b7f17877e886=
8080e9f40c238c6" data-outlook-id=3D"30fefbf0-f004-42ea-818d-55faa8b25323">g=
it</a></span>.=0A=
=0A=
This major release includes new features:=0A=
=0A=
<b>Hybrid IO</b> Automatic performance optimization for large IO (<a href=
=3D"https://jira.whamcloud.com/browse/LU-18033" data-outlook-id=3D"91b91239=
-bd54-4b04-9b61-7b3b16889d89">LU-18033</a>)=0A=
=0A=
<b>Dynamic LNet NID Configuration</b> Improved online configuration of LNet=
 interfaces (<a href=3D"https://jira.whamcloud.com/browse/LU-18815" data-ou=
tlook-id=3D"4f38a238-2b9a-4099-9ce8-9ed81286869a">LU-18815</a>)=0A=
=0A=
<b>Nodemap Enhancements</b> Dynamic Nodemaps to support more sophisticated =
multi-tenancy options &nbsp;(<a href=3D"https://jira.whamcloud.com/browse/L=
U-17431" data-outlook-id=3D"a82dd386-d09d-45b7-af32-fda2de5863d3">LU-17431<=
/a>)=0A=
=0A=
Fuller details about this release can be found in the <a href=3D"https://wi=
ki.lustre.org/Release_2.17.0" data-outlook-id=3D"9383db39-e1ba-483c-9f50-3d=
1a62105430">2.17 wiki page</a> (including the <a href=3D"https://wiki.lustr=
e.org/Lustre_2.17.0_Changelog" data-outlook-id=3D"f66d99e7-39db-436c-aa0d-a=
26489a29e61">change log</a> and <a href=3D"https://wiki.lustre.org/Release_=
2.17.0#Test_Matrix" data-outlook-id=3D"60fe5766-f00b-4485-a500-ff5c78ac7e6f=
">test matrix</a>)=0A=
=0A=
Please log any issues found in the <a href=3D"https://jira.whamcloud.com/" =
data-outlook-id=3D"4cb9e523-327f-4473-bbcd-b84730261d32">issue tracking sys=
tem</a>=0A=
=0A=
Thanks to all those who have contributed to the creation of this release.=
=0A=
=0A=
This release is dedicated to the memory of <b>Frank Sehr</b> who was a memb=
er of the LNet development team. Frank passed away suddenly this summer and=
 is missed by both the Lustre developers and the customers of the <a href=
=3D"https://www.surflodgegabriola.com" data-outlook-id=3D"2c63b6c4-1250-435=
f-a2de-76618e04f5ec">Surf Lodge Pub</a> where he regularly played music.=0A=
</div></pre>
<div dir=3D"ltr" style=3D"font-family: Aptos, Arial, Helvetica, sans-serif;=
 font-size: 12pt; color: rgb(0, 0, 0);">
<br>
<br>
</div>
<div dir=3D"ltr" style=3D"font-family: Aptos, Arial, Helvetica, sans-serif;=
 font-size: 12pt; color: rgb(0, 0, 0);">
<br>
</div>
</body>
</html>

--_000_CH2PR04MB69667BACADFDD0527A4BBDB2CCA0ACH2PR04MB6966namp_--

--===============1620865274803462158==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============1620865274803462158==--
