Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 3E13DCCF9F8
	for <lustre-devel@archiver.kernel.org>; Tue,  4 Nov 2025 02:47:54 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4d0tCt0xxLz1y22;
	Mon, 03 Nov 2025 18:47:38 -0800 (PST)
Received: from outbound-ip191a.ess.barracuda.com
 (outbound-ip191a.ess.barracuda.com [209.222.82.58])
 (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4d0tCg2DXhz1wgn
 for <lustre-devel@lists.lustre.org>; Mon, 03 Nov 2025 18:47:27 -0800 (PST)
Received: from BYAPR05CU005.outbound.protection.outlook.com
 (mail-westusazon11020117.outbound.protection.outlook.com [52.101.85.117]) by
 mx-outbound47-216.us-east-2c.ess.aws.cudaops.com (version=TLSv1.2
 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
 Tue, 04 Nov 2025 02:47:24 +0000
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=Xu0jC0lsn11W5GiGpBmkdmL4OHEnxPaRlxwbk68GVtuQHqr9pp3zdlHC9ExNdtQQLH+ka3uV20Dr/CV1CqJ4CkQqXCrE6jqJ5c+kKtj34xewli/9CjpWjsvImASTKj4sZBmDf7JxEGrhAiMZJgczlCj8IOpLJ69OovdIXgzQ3NaXfYeow38ga7ZrIhLg20hXzraR5iZU7NSaI7sE5ZHi710OMxQdLmrkc+DnKgsLTIMVu5m6z1Uafr/O+ZI3Z4kpacF1XQqe4Si9HgkN9bu6VrtfsiTHDMyYQkGsKgOuVm1sUhrRyMKe79PtZuoNBAzeijSXNn8p91Hok2xjkxWcdg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com; 
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=gjSgrEV4AVPRWaRtPC8qOr5XhAmpHD8nujJkY5BuxM4=;
 b=U5RWTd/2CeH+lbZObFjekkjKglsIj27Hkkw+XaRxYKnw/q4oXBo3BG39yvNAYSQllaOKa5EEujHIw4MWQdQXI8nskCkrNnwokwdkxt5LGTY0rF6RlYCLUXC4lWbDpr0evbQxNUAL+D1bxeVMNh/MlG7bSip1iy3/0/4n0zdTGmdyp2K5DhTjr3dbfk+MoTvqZakTxDcOEIXKmQUWRYqNhC1/WV8aP9kaVz1i3r2wxkH4PxUWC9FYS12GrF+GfgtWoqr2f28Yr8+gRPWy+5z0KIgMVySlelojuPSM1Gh5EZ/MswK2LPq/LqyUwN88QpnIj5NifHOhK6vWFEZp7mNGyg==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=ddn.com; dmarc=pass action=none header.from=ddn.com; dkim=pass
 header.d=ddn.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ddn.com; s=selector2; 
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=gjSgrEV4AVPRWaRtPC8qOr5XhAmpHD8nujJkY5BuxM4=;
 b=ZSMKws5WPyUogXw49IQ766wvtjGZ7D+QnFaMSsNA3xzLtLumnWudyIvRPFVllz9bgJlWHTAPeuHYTx/ElWvU9AGgrZfY5b6zPCLCGXT9WIikw/u8eQ2+mTZHOiWqWLOLiHW497HHluFuRZjNTTE9no8//Z92upZtpxTlPpn3X7g=
Received: from DM6PR19MB2636.namprd19.prod.outlook.com (2603:10b6:5:15f::15)
 by IA3PR19MB8761.namprd19.prod.outlook.com (2603:10b6:208:50e::16) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.9275.16; Tue, 4 Nov
 2025 02:47:21 +0000
Received: from DM6PR19MB2636.namprd19.prod.outlook.com
 ([fe80::48f4:9756:558e:f02c]) by DM6PR19MB2636.namprd19.prod.outlook.com
 ([fe80::48f4:9756:558e:f02c%5]) with mapi id 15.20.9275.013; Tue, 4 Nov 2025
 02:47:21 +0000
To: Oleg Drokin via lustre-devel <lustre-devel@lists.lustre.org>,
 "jinshanx@google.com" <jinshanx@google.com>, Oleg Drokin
 <green@whamcloud.com>
Thread-Topic: [lustre-devel] RFC: Spill device for Lustre OSD
Thread-Index: AQHcTQ0r4j1Aax3hO0uk16UW69NCCrThlTEAgAAN0YCAAAMnAIAABRWAgAAXyYCAAAyKGg==
Date: Tue, 4 Nov 2025 02:47:21 +0000
Message-ID: <DM6PR19MB263631D5057975AB09DB7F60C9C4A@DM6PR19MB2636.namprd19.prod.outlook.com>
References: <e2c69a503e80f3ba59d69f093bc8df519cdd7f66.camel@whamcloud.com>
 <BFDDAAED-BA9A-44DB-BCD0-B3B84E652FE7@gmail.com>
 <c6c016567a02f857303eedb9a4af6b5831c2c818.camel@whamcloud.com>
 <CAEp8vpiZ8iKRbjy8GYKdXFjsycW=a48baOXxUnSP7uE+Xf5cYw@mail.gmail.com>
 <e31f82d56f034cb325ae29a08280122711078a97.camel@whamcloud.com>
In-Reply-To: <e31f82d56f034cb325ae29a08280122711078a97.camel@whamcloud.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=ddn.com;
x-ms-publictraffictype: Email
x-ms-traffictypediagnostic: DM6PR19MB2636:EE_|IA3PR19MB8761:EE_
x-ms-office365-filtering-correlation-id: 3c9a2df0-003a-428a-863c-08de1b4c7a1f
x-ms-exchange-senderadcheck: 1
x-ms-exchange-antispam-relay: 0
x-microsoft-antispam: BCL:0;
 ARA:13230040|19092799006|1800799024|376014|366016|13003099007|8096899003|7053199007|38070700021;
x-microsoft-antispam-message-info: =?Windows-1252?Q?zHCC3pjOTg4o10ElmADd43ULzfN6pWyTVscD8AdSZrxphgpunLnXqm9O?=
 =?Windows-1252?Q?ovuynAN8XPJSJGj83wKm7maxbT0lMyfyr6QX8yW009uR892BLilFGWQb?=
 =?Windows-1252?Q?Ex5FHnxxxL4L4+a9ysw2wpIovG0BWhFiNQV5arvt3AWEyu0TQrgVg5cc?=
 =?Windows-1252?Q?W9rLjlu3uqRng6dPlPrMPPUs/8coyHM9BGn+seIED0z2iMJyhdUgBgHD?=
 =?Windows-1252?Q?dVf4mWgys9cGIiRT36Daeb4NbNx31/CF/vVhHy7ORbnxliHlPyJCeM/a?=
 =?Windows-1252?Q?Rh9JBym30oyPn8wmxS9qEDBRLrqxlsXTuWHl+j01jF+mZFjSRQTYePY1?=
 =?Windows-1252?Q?8X1NPWzuOAliySYH80q9ZqZp9Mx3GHabM3aODEiXF2S7IBnLDmOq3W9S?=
 =?Windows-1252?Q?PdxJ5Ht5IRnbvfSy20FYXNxCWd/msB946uJO4kyHmZ0AP3Zk/e1RaQRA?=
 =?Windows-1252?Q?vdDBi74s8UEMUoiNQ4E9Kj1OGzdFCogxnyQBjCUqBF8cxA8sd/xXc5cc?=
 =?Windows-1252?Q?lj6vFqbuIYjnftXHRAIBh6UEVoVEzK6Db8B04LOBMub185Jth9OpCpXr?=
 =?Windows-1252?Q?maSDVs/2W9KG2llOuG8/FKi7OJFMgLVN5Lm3RPqlSi7NukS0ve9BGr4Z?=
 =?Windows-1252?Q?NH1ssRe4eHLql/6lLQMnJQuxV0Ug6STSCAn4XvIZoTKXY6DE/k4xrjfD?=
 =?Windows-1252?Q?zFpgVH0wLn6/XpN3x+ZkI/BrUclmwRG0ydY7EMPOlbkR1n6DPYVAoYXK?=
 =?Windows-1252?Q?j9yJ0xtc6TngpMl0Uq+zMgh/CGN1WScKGlgHiFZWeKt2NFmEBXscpSLh?=
 =?Windows-1252?Q?Kn8jwkZYMTS6nF6e92NHq32+CtvLat0PlEhYgd2bRqsvJF2y5kd8PblY?=
 =?Windows-1252?Q?jPfe0E/TmNkhcVBhf02uOG6bf4f6BGRVygNI+CO7Ztr/JM6HmMr3oZ1L?=
 =?Windows-1252?Q?oF1BeMRQfknD0/4KtOhKgx19NpoYtgr8aAwg7NJcfxhArtW2v04kOCua?=
 =?Windows-1252?Q?K2OaSTrA5Lw0QWrhGXgKx7WLKuf1RNel2e4TnKinROMXNcYE0eEBsHey?=
 =?Windows-1252?Q?fqEiQ8YG6Q9mhsIPE1goyowBeJocvTQKaW6zg1rZ1BjNiH2vp0QSWsvK?=
 =?Windows-1252?Q?jDpvpHkvCd0FgHr3a5UiWx8Riw0dhb51nRn5Rf4WTQKxl3znB1DFfRZf?=
 =?Windows-1252?Q?sCgkN5SCiBh5HInK6YmDqGpbkQsa7k3KoCBJY3R2D6yLDqqcLSH+oVd7?=
 =?Windows-1252?Q?cqupJDwMrm3o1E70ByWKD6c4/KDS3onBu369ktAstmhPfloexkPKNk5W?=
 =?Windows-1252?Q?scPHeiMRiRqCvQDrbhGn7IHN/plblb0h3fflGF14swINJwEgNWAe6Gbb?=
 =?Windows-1252?Q?+Agz1AwvNtlityL8zovdtSec6P6kguv/wY2UPqpEljpOfVRBl1gLgdoX?=
 =?Windows-1252?Q?2bNh8jDQIBNx6e61C0pdLYYA1Vx/jMPz+t/dWHTKcyYl0NYn17O2vYtc?=
 =?Windows-1252?Q?A+ZWXm7ih7xHwEkd7ixu6wJ/bv+xy+a05TrUaVHY3zY1ARd0QfL8iLnF?=
 =?Windows-1252?Q?8wbgiiyIJv9Oi7tYHJSnTyxbgGBbD52G4Tqbgts01xBlJyaAxIcey8ds?=
 =?Windows-1252?Q?yeD4SX/50feHVct96d/h/fxs?=
x-forefront-antispam-report: CIP:255.255.255.255; CTRY:; LANG:en; SCL:1; SRV:;
 IPV:NLI; SFV:NSPM; H:DM6PR19MB2636.namprd19.prod.outlook.com; PTR:; CAT:NONE;
 SFS:(13230040)(19092799006)(1800799024)(376014)(366016)(13003099007)(8096899003)(7053199007)(38070700021);
 DIR:OUT; SFP:1102; 
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0: =?Windows-1252?Q?XAC/RjyGkHpUAN0ks7jBIVcq04O5G28KdNDZOA4VK5x28co+GL5Yz8Oj?=
 =?Windows-1252?Q?R9QlpgKC+FoQ8FdbCZO3xU09c78DYHpoIS8a60t0poGsV/ovnNd7Xit/?=
 =?Windows-1252?Q?98m0s6ihmgGNnmdgyiE4sFYOksVrE/psE2ocUtOP2SWE8mA4KOE5vKO+?=
 =?Windows-1252?Q?07C35wpuZj2hinM8pPdDYCwKc2ITUq/ALvqAdLGloyLGQAyfMEl/mD4B?=
 =?Windows-1252?Q?iJ18wK3IChfxmvdANVo+JW5I2PqBFYVBRMb+IDnYByCDolOSogTLpbZ/?=
 =?Windows-1252?Q?OrbwDao046q9nB0qDwgCzotC5GQEUQ/N+TWchWDJBx0sOCaNK1wDcKRD?=
 =?Windows-1252?Q?xgR1eTbiaXyVrXHILIPPImrJmDsKYwIL2h1w3/dihkAcESoozVuQVoND?=
 =?Windows-1252?Q?VdFwAJ9HhjNg3uU2l9vdVtaLj3ua5acfifVbf0lvoi8a5waYKnxq9y0m?=
 =?Windows-1252?Q?BXiDh6uoPBnI87lNAaETmwapiV7xSA5VeA3/0t2MzIamiwUR/e2FzXZI?=
 =?Windows-1252?Q?NtGoALl7F+r6U+Am/wxU/dwLLqXyWhimciw/Uwt/gNUmPmJGgzzCaSpe?=
 =?Windows-1252?Q?F3/dU8qOJksWfMGqMv+GZXDcoVVKHQHaQ+TtWVyN01hOhJhHC8TALQkD?=
 =?Windows-1252?Q?bnkkLAsmmXk5vSGZ4BSsjl4yW+RVZCvF4GMprroT4TtKpB1HXEKjmJr+?=
 =?Windows-1252?Q?LcCQxKIP/VsDjmC+CiVYYg7fHxJNe25+KB3B+CQmhLWpxNgixoLi63f9?=
 =?Windows-1252?Q?E1eM/wh2kQ6z3+0Nq/rXrNpDRZNgCExyD7DIypQy1tsZjrU3ce1dNO+7?=
 =?Windows-1252?Q?mElYCjcIRCoveAl2jHHspNCMB2mXS1/LLUJNDGsUpvTjIB6TBpHAk5/T?=
 =?Windows-1252?Q?3NJJmxJ3givJsSYLnft7ui9aRDzqAdN4inserAFIrnvWGFLszVqiv3n4?=
 =?Windows-1252?Q?t0pVv8wzk62CuoBUGse2IxGglt9NlmSCKz9tim6MLUxvf0fot3+hR8Vg?=
 =?Windows-1252?Q?Qd3KIbWPHQmAV4yg/zBdsjUNBCJI+jiYXsrUMk+hkk62IH4AlaiMJ/Sh?=
 =?Windows-1252?Q?kU2hVNvbCw5SquZT3OwLJGXijUNAgTbRUVXKUU6EMxed33mssrNm2TI8?=
 =?Windows-1252?Q?NlmwPu26KRuxFsadMVColZvOyklUo42bk3RNwXlFf5yCEtmLIo80FTXp?=
 =?Windows-1252?Q?UR62cHsrS4952jXi0yzDQ7GHibMmNMBOob8zTmGazfqFnAjHUc3qT1Jx?=
 =?Windows-1252?Q?oxCwBsvWCf4pS3eBhULOZcfMJgqDYBUDamhutZrqalSRK4EyW1XztEuj?=
 =?Windows-1252?Q?9dvThy38cwIZjUuTHp2n/hvBpZezt7M8MueUng8WU3d0ZXIzW38qBYKS?=
 =?Windows-1252?Q?eEAZrcRMEH5ij46e4eSTibD7hstautsnK6jNxipRSMKTTtyfn5v8RoBl?=
 =?Windows-1252?Q?owY5owu/7ALU8rqf9Izq+uyU8DezL56uL565D/L1T6UuSOB3C/jo7CMr?=
 =?Windows-1252?Q?0W/2g4KaEeBobWA2TN6Og4W0TlL4Nqk+j08tfBmp6RIKswktZx30T06V?=
 =?Windows-1252?Q?qjEr5VwO5g563oBB5cnJNWZahofjefEQmaXVQw2kJbVWP17/fWqiKmYo?=
 =?Windows-1252?Q?nDP2H6NMINw4RK6CPqBAWcjFQgbxixZgGMNZvDG1Ur6fvsQttsR+TSxA?=
 =?Windows-1252?Q?/LaHUV6kBDM=3D?=
MIME-Version: 1.0
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-0: 7nbYmlL1C/ZS+zi+ORY0XYKv2AXhCdlSFwCjcrj+mzsCreWJXJj5yc8EjmNp7BOaZo0xdORodq3M3/1vZJgpHQBh21yyToa1jHA9gbZshabvoBYeLzuCQu6kEnvIC8nAHsjP1/eO2XkvFoEh4PBkDb3+SCdwYIC4WKdjWWXm/wZbMakB+yP5sj1MB+RZzACDXdtQF1pwrU9cB8YNinOA91glTKOlX1VwAinQRtjBUYroKkSvJY4kyBOgIRHBc/SNx84xDHtKzKs1eKXkZOPSsS4rvXjnZysim9KLo1rv/7Uei6ChueNlh6ZaKu6OnxASMXRpBN/hYQJnhqq10VcP0wjN+5vw77RofBXPN5/WHQ93Uk75y9be6MQcoFhD2dLK88a39C+UV2NQkkD1AkS9kLQX6fO4GDa7xvQnuCSGJ8GEHpTeQlhDO9qPDz/tyGDmuJFdX9R5EJcjhGKClW3fPSO3q4PSkxAqi1eyHs02HcWS71kSwsXylLAIBuwNKgzSlGufbmw7ny7qwedrHm+6ailqzdqLez01dCvwfb48ZjtcAqX5ErVjS6lQBzogN6vGa2jC3bFB108BE9rpoub0H9ncPZd+SxpF2x3holzaoJf32dXTHF8qB8CIstrJYZXe2vjP20sft6BNU3dPT4tErQ==
X-OriginatorOrg: ddn.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: DM6PR19MB2636.namprd19.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 3c9a2df0-003a-428a-863c-08de1b4c7a1f
X-MS-Exchange-CrossTenant-originalarrivaltime: 04 Nov 2025 02:47:21.2931 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 753b6e26-6fd3-43e6-8248-3f1735d59bb4
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: v++DMXN5cHJ/7Qkv7B4mLOUJb5F29KFAPj6ZUhTLb1T9iH1pCd89Ckj1ruoXcdoB8h/tXS5NQHJQcok7hKBBZA==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: IA3PR19MB8761
X-BESS-ID: 1762224444-112248-9743-7244-1
X-BESS-VER: 2019.1_20251103.1605
X-BESS-Apparent-Source-IP: 52.101.85.117
X-BESS-Parts: H4sIAAAAAAACAzXMsQqGMAwE4HfJ7JA0Nml9FXFI24DLj4MdBPHd7eC/HMfBd+
 sNfnVYoI+c4DhhEWYabR9jY5wDExYVNg2OzT1xqCbUMlKCZ/r7vf8+n0Tx87EiS1bL0Y
 jdNWotVAyjjz9KAZ7tBdEXHtWBAAAA
X-BESS-Outbound-Spam-Score: 0.10
X-BESS-Outbound-Spam-Report: Code version 3.2,
 rules version 3.2.2.268692 [from 
 cloudscan14-254.us-east-2a.ess.aws.cudaops.com]
 Rule breakdown below
 pts rule name              description
 ---- ---------------------- --------------------------------
 0.00 HTML_MESSAGE           BODY: HTML included in message 
 0.10 BSF_SC0_SA085          META: Custom Rule SA085 
 0.00 BSF_BESS_OUTBOUND      META: BESS Outbound 
X-BESS-Outbound-Spam-Status: SCORE=0.10 using account:ESS124931 scores of
 KILL_LEVEL=7.0 tests=HTML_MESSAGE, BSF_SC0_SA085, BSF_BESS_OUTBOUND
X-BESS-BRTS-Status: 1
Subject: Re: [lustre-devel] RFC: Spill device for Lustre OSD
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
From: Patrick Farrell via lustre-devel <lustre-devel@lists.lustre.org>
Reply-To: Patrick Farrell <pfarrell@ddn.com>
Content-Type: multipart/mixed; boundary="===============3701145815734774479=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============3701145815734774479==
Content-Language: en-US
Content-Type: multipart/alternative;
	boundary="_000_DM6PR19MB263631D5057975AB09DB7F60C9C4ADM6PR19MB2636namp_"

--_000_DM6PR19MB263631D5057975AB09DB7F60C9C4ADM6PR19MB2636namp_
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: quoted-printable

I haven=92t seen any mention of failover yet in this conversation (may have=
 missed it), but if the device is truly local, then in failed over configur=
ations the data is inaccessible.  If it=92s *not* local, why not just make =
the device part of the OST or an independent OST?

Or even if it is local only - it could be made an OST
________________________________
From: lustre-devel <lustre-devel-bounces@lists.lustre.org> on behalf of Ole=
g Drokin via lustre-devel <lustre-devel@lists.lustre.org>
Sent: Monday, November 3, 2025 7:58 PM
To: jinshanx@google.com <jinshanx@google.com>
Cc: lustre-devel@lists.lustre.org <lustre-devel@lists.lustre.org>
Subject: Re: [lustre-devel] RFC: Spill device for Lustre OSD

On Mon, 2025-11-03 at 16:33 -0800, Jinshan Xiong wrote:
> > > >
> > > > I am not sure it's a much better idea than the already existing
> > > > HSM
> > > > capabilities we have that would allow you to have "offline"
> > > > objects
> > > > that would be pulled back in when used, but are otherwise just
> > > > visible
> > > > in the metadata only.
> > > > The underlying capabilities are pretty rich esp. if we also
> > > > take
> > > > into
> > > > account the eventual WBC stuff.
> > >
> > > The major problem of current HSM is that it has to have dedicated
> > > clients to move data. Also, scanning the entire Lustre file
> > > system
> >
> > This (dedicated client) is an implementation detail. It could be
> > improved in many ways and the effort spent on this would bring
> > great
> > benefit to everyone?
>
>
> Almost all designs assume some upfront implementation. We (as the
> Lustre team) considered running clients on OST nodes, but cloud users
> are sensitive about their data being exposed elsewhere.
>
> Can you list a few improvements that come to mind?

Clients between server nodes is probably one of the most obvious
choices indeed. Considering the data already resides on those nodes, I
am not sure I understand the concerns about "exposing" data that's
already on those nodes. If customers are so sensitive, we support data
encryption.
We could also do some direct server-server migration of some sort where
OSTs exchange data without bringing up real clients and doing copies
from userspace. That might be desirable for other reasons for future
functionality (e.g. various caching things people have been long
envisioning)

> >
> > > takes very long time so it resorts to databases in order to make
> > > correct decisions about which file should be released. By the
> > > time,
> > > the two system will be out of sync. That makes it practically
> > > unusable.
> >
> > This again is an implementation detail, not even hardcoded
> > anywhere.
> > How do you plan for the OST to to know what stuff is not used
> > without
> > resorting to some database or scan? Now take this method and make
> > it
> > report "upstream" where currently HSM implementations resort to
> > databases or scans.
> >
>
> The assumption is that OST sizes are relatively small, up to 100TB.
> Also, scanning local devices in kernel spaces is much faster. So yeah
> there is no database in the way.

I am not sure why? In general small OSTs are a relatively rare thing
because to reach large FS sizes you would need to many of them, space
balancing becomes a chore and so on. So relatively few do it for some
fringe reasons (e.g. Google) . Majority of people prefer large OSTs.

Also nothing stops you from doing a per-OST scan (when you do have
small OSTs) and then kicking the results up to the acting agent to do
something about it (or the other way around, the hsm engine can ask
OSTs one by one (picking less busy ones or ones that have the least
free space, or some other factor). And there's absolutely no need to
wait out to query all OSTs, you can get results from one and work on
the data from it while the other OSTs are still thinking (or not,
there's absolutely no requirement to get full filesystem data before
making any decisions).

> I guess users won't have 1PB OSTs, will they?

There probably are already? NASA has a known 0.5P OST configuration:
https://www.nas.nasa.gov/hecc/support/kb/lustre-progressive-file-layout-(pf=
l)-with-ssd-and-hdd-pools_680.html#:~:text=3DThe%20available%20SSD%20space%=
20in%20each%20filesystem,decimal%20(far%20right)%20labels%20of%20each%20OST
.

> > Rereading your proposal, I see that this particular detail is not
> > covered and it's just assumed that "infrequently accessed data"
> > would
> > be somehow known.
>
> I should have mentioned that in the migration section. Also, we need
> to slightly update the OST read to use a local transaction to update
> an object's access time (atime) if it's older than a predefined
> threshold, for example, 10 minutes.

This is going to be fragile in the face of varying clock times on
different clients potentially not synced with the servers.
Also in the face of -o noatime.

But yes, I guess it's one way to get this "on the cheap", and the other
trouble I foresee is you are going to have a biased set. Only recently
touched objects (so with fresh atime), unless you plan to retain a
database and update it from such transaction flow, which certainly is
possible, but I am not sure how practical vs some sort of a scan.

> > > > If the argument is "but OSTs know best what stuff is used"
> > > > (which I
> > > > am
> > > > not sure I buy, after all before you could use something off
> > > > OSTs
> > > > you
> > > > need to open a file I would hope) even then OSTs could just
> > > > signal
> > > > a
> > > > list of "inactive objects" that then a higher level system
> > > > would
> > > > take
> > > > care of by relocatiing somewhere more sensical and changing the
> > > > layout
> > > > to indicate those objects now live elsewhere.
> > > >
> > > > The plus here is you don't need to attach this "Wart" to every
> > > > OST
> > > > and
> > > > configure it everywhere and such, but rather have a central
> > > > location
> > > > that is centrally managed.
> > > >
> >
> > _______________________________________________
> > lustre-devel mailing list
> > lustre-devel@lists.lustre.org
> > http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
> >

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--_000_DM6PR19MB263631D5057975AB09DB7F60C9C4ADM6PR19MB2636namp_
Content-Type: text/html; charset="Windows-1252"
Content-Transfer-Encoding: quoted-printable

<html>
<head>
<meta http-equiv=3D"Content-Type" content=3D"text/html; charset=3DWindows-1=
252">
</head>
<body>
<div><span style=3D"-webkit-text-size-adjust: 100%;">I haven=92t seen any m=
ention of failover yet in this conversation (may have missed it), but if th=
e device is truly local, then in failed over configurations the data is ina=
ccessible. &nbsp;If it=92s *not* local, why
 not just make the device part of the OST or an independent OST?</span><br>
</div>
<div><br>
</div>
<div>Or even if it is local only - it could be made an OST</div>
<div></div>
<hr style=3D"display:inline-block;width:98%" tabindex=3D"-1">
<div id=3D"divRplyFwdMsg" dir=3D"ltr"><font face=3D"Calibri, sans-serif" st=
yle=3D"font-size:11pt" color=3D"#000000"><b>From:</b> lustre-devel &lt;lust=
re-devel-bounces@lists.lustre.org&gt; on behalf of Oleg Drokin via lustre-d=
evel &lt;lustre-devel@lists.lustre.org&gt;<br>
<b>Sent:</b> Monday, November 3, 2025 7:58 PM<br>
<b>To:</b> jinshanx@google.com &lt;jinshanx@google.com&gt;<br>
<b>Cc:</b> lustre-devel@lists.lustre.org &lt;lustre-devel@lists.lustre.org&=
gt;<br>
<b>Subject:</b> Re: [lustre-devel] RFC: Spill device for Lustre OSD</font>
<div>&nbsp;</div>
</div>
<div class=3D"BodyFragment"><font size=3D"2"><span style=3D"font-size:11pt;=
">
<div class=3D"PlainText">On Mon, 2025-11-03 at 16:33 -0800, Jinshan Xiong w=
rote:<br>
&gt; &gt; &gt; &gt; <br>
&gt; &gt; &gt; &gt; I am not sure it's a much better idea than the already =
existing<br>
&gt; &gt; &gt; &gt; HSM<br>
&gt; &gt; &gt; &gt; capabilities we have that would allow you to have &quot=
;offline&quot;<br>
&gt; &gt; &gt; &gt; objects<br>
&gt; &gt; &gt; &gt; that would be pulled back in when used, but are otherwi=
se just<br>
&gt; &gt; &gt; &gt; visible<br>
&gt; &gt; &gt; &gt; in the metadata only.<br>
&gt; &gt; &gt; &gt; The underlying capabilities are pretty rich esp. if we =
also<br>
&gt; &gt; &gt; &gt; take<br>
&gt; &gt; &gt; &gt; into<br>
&gt; &gt; &gt; &gt; account the eventual WBC stuff.<br>
&gt; &gt; &gt; <br>
&gt; &gt; &gt; The major problem of current HSM is that it has to have dedi=
cated<br>
&gt; &gt; &gt; clients to move data. Also, scanning the entire Lustre file<=
br>
&gt; &gt; &gt; system<br>
&gt; &gt; <br>
&gt; &gt; This (dedicated client) is an implementation detail. It could be<=
br>
&gt; &gt; improved in many ways and the effort spent on this would bring<br=
>
&gt; &gt; great<br>
&gt; &gt; benefit to everyone?<br>
&gt; <br>
&gt; <br>
&gt; Almost all designs assume some upfront implementation. We (as the<br>
&gt; Lustre team) considered running clients on OST nodes, but cloud users<=
br>
&gt; are sensitive about their data being exposed elsewhere.<br>
&gt; <br>
&gt; Can you list a few improvements that come to mind?<br>
<br>
Clients between server nodes is probably one of the most obvious<br>
choices indeed. Considering the data already resides on those nodes, I<br>
am not sure I understand the concerns about &quot;exposing&quot; data that'=
s<br>
already on those nodes. If customers are so sensitive, we support data<br>
encryption.<br>
We could also do some direct server-server migration of some sort where<br>
OSTs exchange data without bringing up real clients and doing copies<br>
from userspace. That might be desirable for other reasons for future<br>
functionality (e.g. various caching things people have been long<br>
envisioning)<br>
&nbsp;<br>
&gt; &gt; <br>
&gt; &gt; &gt; takes very long time so it resorts to databases in order to =
make<br>
&gt; &gt; &gt; correct decisions about which file should be released. By th=
e<br>
&gt; &gt; &gt; time,<br>
&gt; &gt; &gt; the two system will be out of sync. That makes it practicall=
y<br>
&gt; &gt; &gt; unusable.<br>
&gt; &gt; <br>
&gt; &gt; This again is an implementation detail, not even hardcoded<br>
&gt; &gt; anywhere.<br>
&gt; &gt; How do you plan for the OST to to know what stuff is not used<br>
&gt; &gt; without<br>
&gt; &gt; resorting to some database or scan? Now take this method and make=
<br>
&gt; &gt; it<br>
&gt; &gt; report &quot;upstream&quot; where currently HSM implementations r=
esort to<br>
&gt; &gt; databases or scans.<br>
&gt; &gt; <br>
&gt; <br>
&gt; The assumption is that OST sizes are relatively small, up to 100TB.<br=
>
&gt; Also, scanning local devices in kernel spaces is much faster. So yeah<=
br>
&gt; there is no database in the way.<br>
<br>
I am not sure why? In general small OSTs are a relatively rare thing<br>
because to reach large FS sizes you would need to many of them, space<br>
balancing becomes a chore and so on. So relatively few do it for some<br>
fringe reasons (e.g. Google) . Majority of people prefer large OSTs.<br>
<br>
Also nothing stops you from doing a per-OST scan (when you do have<br>
small OSTs) and then kicking the results up to the acting agent to do<br>
something about it (or the other way around, the hsm engine can ask<br>
OSTs one by one (picking less busy ones or ones that have the least<br>
free space, or some other factor). And there's absolutely no need to<br>
wait out to query all OSTs, you can get results from one and work on<br>
the data from it while the other OSTs are still thinking (or not,<br>
there's absolutely no requirement to get full filesystem data before<br>
making any decisions).<br>
<br>
&gt; I guess users won't have 1PB OSTs, will they?<br>
<br>
There probably are already? NASA has a known 0.5P OST configuration:<br>
<a href=3D"https://www.nas.nasa.gov/hecc/support/kb/lustre-progressive-file=
-layout-(pfl)-with-ssd-and-hdd-pools_680.html#:~:text=3DThe%20available%20S=
SD%20space%20in%20each%20filesystem,decimal%20(far%20right)%20labels%20of%2=
0each%20OST">https://www.nas.nasa.gov/hecc/support/kb/lustre-progressive-fi=
le-layout-(pfl)-with-ssd-and-hdd-pools_680.html#:~:text=3DThe%20available%2=
0SSD%20space%20in%20each%20filesystem,decimal%20(far%20right)%20labels%20of=
%20each%20OST</a><br>
.<br>
<br>
&gt; &gt; Rereading your proposal, I see that this particular detail is not=
<br>
&gt; &gt; covered and it's just assumed that &quot;infrequently accessed da=
ta&quot;<br>
&gt; &gt; would<br>
&gt; &gt; be somehow known.<br>
&gt; <br>
&gt; I should have mentioned that in the migration section. Also, we need<b=
r>
&gt; to slightly update the OST read to use a local transaction to update<b=
r>
&gt; an object's access time (atime) if it's older than a predefined<br>
&gt; threshold, for example, 10 minutes.&nbsp;<br>
<br>
This is going to be fragile in the face of varying clock times on<br>
different clients potentially not synced with the servers.<br>
Also in the face of -o noatime.<br>
<br>
But yes, I guess it's one way to get this &quot;on the cheap&quot;, and the=
 other<br>
trouble I foresee is you are going to have a biased set. Only recently<br>
touched objects (so with fresh atime), unless you plan to retain a<br>
database and update it from such transaction flow, which certainly is<br>
possible, but I am not sure how practical vs some sort of a scan.<br>
<br>
&gt; &gt; &gt; &gt; If the argument is &quot;but OSTs know best what stuff =
is used&quot;<br>
&gt; &gt; &gt; &gt; (which I<br>
&gt; &gt; &gt; &gt; am<br>
&gt; &gt; &gt; &gt; not sure I buy, after all before you could use somethin=
g off<br>
&gt; &gt; &gt; &gt; OSTs<br>
&gt; &gt; &gt; &gt; you<br>
&gt; &gt; &gt; &gt; need to open a file I would hope) even then OSTs could =
just<br>
&gt; &gt; &gt; &gt; signal<br>
&gt; &gt; &gt; &gt; a<br>
&gt; &gt; &gt; &gt; list of &quot;inactive objects&quot; that then a higher=
 level system<br>
&gt; &gt; &gt; &gt; would<br>
&gt; &gt; &gt; &gt; take<br>
&gt; &gt; &gt; &gt; care of by relocatiing somewhere more sensical and chan=
ging the<br>
&gt; &gt; &gt; &gt; layout<br>
&gt; &gt; &gt; &gt; to indicate those objects now live elsewhere.<br>
&gt; &gt; &gt; &gt; <br>
&gt; &gt; &gt; &gt; The plus here is you don't need to attach this &quot;Wa=
rt&quot; to every<br>
&gt; &gt; &gt; &gt; OST<br>
&gt; &gt; &gt; &gt; and<br>
&gt; &gt; &gt; &gt; configure it everywhere and such, but rather have a cen=
tral<br>
&gt; &gt; &gt; &gt; location<br>
&gt; &gt; &gt; &gt; that is centrally managed.<br>
&gt; &gt; &gt; &gt; <br>
&gt; &gt; <br>
&gt; &gt; _______________________________________________<br>
&gt; &gt; lustre-devel mailing list<br>
&gt; &gt; lustre-devel@lists.lustre.org<br>
&gt; &gt; <a href=3D"http://lists.lustre.org/listinfo.cgi/lustre-devel-lust=
re.org">http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org</a><br=
>
&gt; &gt; <br>
<br>
_______________________________________________<br>
lustre-devel mailing list<br>
lustre-devel@lists.lustre.org<br>
<a href=3D"http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org">ht=
tp://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org</a><br>
</div>
</span></font></div>
</body>
</html>

--_000_DM6PR19MB263631D5057975AB09DB7F60C9C4ADM6PR19MB2636namp_--

--===============3701145815734774479==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============3701145815734774479==--
