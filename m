Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id CC255CCF9E3
	for <lustre-devel@archiver.kernel.org>; Tue,  4 Nov 2025 23:40:50 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4d1PgB3f6vz235f;
	Tue, 04 Nov 2025 15:24:38 -0800 (PST)
Received: from outbound-ip168b.ess.barracuda.com
 (outbound-ip168b.ess.barracuda.com [209.222.82.102])
 (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4d1PSd3Jzlz20dj
 for <lustre-devel@lists.lustre.org>; Tue, 04 Nov 2025 15:15:29 -0800 (PST)
Received: from BL2PR02CU003.outbound.protection.outlook.com
 (mail-eastusazon11021073.outbound.protection.outlook.com [52.101.52.73]) by
 mx-outbound17-157.us-east-2b.ess.aws.cudaops.com (version=TLSv1.2
 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
 Tue, 04 Nov 2025 23:14:56 +0000
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=F71u96R3Ad3NRG6kQElyA2S7n5SqPYVwa7uuPJCJhHzBxHNnC9MljBA/xJm/Q24twHF6yc1QfjGgiLSEZRWjEMlBRfvqvpI0FklqHijiPHMnhl6qsYpoK3FaUVka4gZkeiLmUN2izso+97FWkWWz1pbZ92w8h2CDxvR8PfLRp/c/r7nr5v94SIvDutjWI77PuuEFhz8SCMjo73XPerlX+FlyOMEZuRIkCccu4hMHRVHfXpo51btD/aEHRESZcf0j7xot7VzucyxUhKJ7Vc6SvS0wW3x/ncwV2k2PbyFiDWYzFttG13ytiwq9P6gJWe0/On2auWzv0SV1LXX+IMZ2tg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com; 
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=sRdxrU+t2Cbxxy1kN06s/eDAqanubasf+jpyJblmj7A=;
 b=Q4aKeacIkPRCGUdO7K/38Ay1WgkcbTWhD0tVJuu72dnFaL4zJF9ILLhcA/z5Fbe/f12HPhCkB1gsxYNu7m7p2GGVu/MF36ieaHTtPyoi94LI2ZFu50y2BWviSrso321dGhYtlyj4ZEUyErj7S8LMAKzisiGyQn+yRIOBtwKV+PqhPkt2CqjXS9sjSgOU9aILOThEgxDHgIiqyKuNoaqWlglDJpWcDeUqjBqCDsaNRDUGCNp9HeuOEX+TRHsFtuUhu/2VLLVtuXRcShEScdKQlA/PhEgE6uMpIfvIQMy2nboQqVfapz41ZbTMf1JJUqfVpYyO0PsF4BjPofXG2SDlcA==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=whamcloud.com; dmarc=pass action=none
 header.from=whamcloud.com; dkim=pass header.d=whamcloud.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=whamcloud.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=sRdxrU+t2Cbxxy1kN06s/eDAqanubasf+jpyJblmj7A=;
 b=KjDpihuJktrs8vUMXDCuWDfJ207RziPKJgx8D0sOVwqiiOmhXIOxV+LzTuy0p59PiA1pg+E1nO7z/2X/3+NM2sxHV/7VDEpSeCdEhvp9Bh7/sbAt7HM3JfsyHqzT+dXGGpF4zYpttAQa4eLYdajWqorRyeYbtnrC9KnwNCDbmzQ=
Received: from DM3PPF12B913643.namprd19.prod.outlook.com
 (2603:10b6:f:fc00::70b) by PH0PR19MB5364.namprd19.prod.outlook.com
 (2603:10b6:510:f6::15) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.9298.7; Tue, 4 Nov
 2025 23:14:53 +0000
Received: from DM3PPF12B913643.namprd19.prod.outlook.com
 ([fe80::1dae:cea7:3265:124e]) by DM3PPF12B913643.namprd19.prod.outlook.com
 ([fe80::1dae:cea7:3265:124e%7]) with mapi id 15.20.9275.015; Tue, 4 Nov 2025
 23:14:52 +0000
To: "timday@amazon.com" <timday@amazon.com>, Andreas Dilger <adilger@ddn.com>
CC: Andreas Dilger <adilger@whamcloud.com>, "lustre-devel@lists.lustre.org"
 <lustre-devel@lists.lustre.org>
Thread-Topic: [lustre-devel] RFC: Spill device for Lustre OSD
Thread-Index: AQHcTdE3vAJsRcuMvkipzEc0Fj6IrrTjI9oAgAACKIA=
Date: Tue, 4 Nov 2025 23:14:52 +0000
Message-ID: <437b0b502c6f00cc728b2b4d0decfc44ae7ecc52.camel@whamcloud.com>
References: <CFE3C4C8-104E-4F7F-A52E-21B8957FAC0F@amazon.com>
 <0092A54A-6EEF-4CD3-8AFD-7B0066A08810@gmail.com>
 <D8E0F0C0-1A5F-413A-82EA-F3CFA473D2E1@amazon.com>
 <28B74585-1877-4A33-9218-FD50AE72D33D@ddn.com>
In-Reply-To: <28B74585-1877-4A33-9218-FD50AE72D33D@ddn.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=whamcloud.com;
x-ms-publictraffictype: Email
x-ms-traffictypediagnostic: DM3PPF12B913643:EE_|PH0PR19MB5364:EE_
x-ms-office365-filtering-correlation-id: 3a5b498a-c954-4843-16ee-08de1bf7f5d0
x-ms-exchange-senderadcheck: 1
x-ms-exchange-antispam-relay: 0
x-microsoft-antispam: BCL:0; ARA:13230040|376014|1800799024|366016|38070700021;
x-microsoft-antispam-message-info: =?utf-8?B?WmsxaG50SzFndmJ4QmRGTzFOMmU0Q0lsRWYyZ2ZrYXB1SEJwL2FYWXhoV24r?=
 =?utf-8?B?RWxVdnZHWWN1TXpYQ0pZUkxXWVZUNFFsZkhMdzFYcGJXd2s1WWxqM3FYcUxO?=
 =?utf-8?B?Tjd2TlAzVTZsSjcvdS9LbDVIbkh1dmpyZzV4RXdVT2hkZW9Ya1FyOEZFd29m?=
 =?utf-8?B?NUpmOHFIZ2NiWVI5eXpXeWRlMnNZZXhoeVl3NGVkWVkzN09OUXN6SUJHQzgz?=
 =?utf-8?B?TDZxcEcvVkNsN1VaWFNJMk8rZWtsLy9mZHd2azZKWmxqUkx3VjhqcDJmb0dq?=
 =?utf-8?B?TzByZVVQNWtsbWtwOUR1aHpFOUdodzZSWVZnZ0VidlFkcVR6WFFEclkxK0Zt?=
 =?utf-8?B?NVNEbDYxaEhndjNxNGZGN29OZGk5RU9DQkJVSGJxd2pIZTlEcTZtYzVRdmpN?=
 =?utf-8?B?MFlJclh1UnNWR2tuTmRJa1VxdXVUV0FEZVc3RnpadXJnbkRYTjlybyswaWRy?=
 =?utf-8?B?cy8xSktSVXQ1dUpVNUZuM0ZWMzBEL05QdUhMQmFtOXNmS0pzZDk1ajBXR1pZ?=
 =?utf-8?B?dVR2c3p4Snd3SE0yKzBDdGRIUXowaGlEYXhQZ0thNU1qRXU0OHNVZU5ZNkt2?=
 =?utf-8?B?OGZmUCtSVGRqakhsT09XSDNObUY3MHdVZy83SGk4YlI0UWZNWTM4TG9jOGhW?=
 =?utf-8?B?eGQzL2p6MGd1TGQ5NW9PMCtWNjZpWFF4VElZVnU0aGZzdHZyZ0FIRERVeTZj?=
 =?utf-8?B?ckc1aTZmVzM1c1pDUk5WTTh5bFFtS1pTZzRPOHRqT01PSTZBUmRoNTlIZlBr?=
 =?utf-8?B?UW9iaDlEYlhzUjVjMTE3QlQ2RlRtL1dQUS9lN3c3NDFGZ1FtZVVoN1lIRjRp?=
 =?utf-8?B?NFhwbHdtc2dPR0lIa0Y1QTZSblFZSGtZMTlLcDd0L0MyT2xFOC9vUFZ2SFdT?=
 =?utf-8?B?ZGZLdGNNWkpNelg4dm1zdGx3aFczOEIrYUVNUGl5dlBLUk5oMzhrUHJoTTIy?=
 =?utf-8?B?WDhNNlVkMXl4a1BROGpucGdpanhxeHQ4ZVE2WWludEEwS0ptSVZIS2hJanpo?=
 =?utf-8?B?OFhwRjg4Y0VyRHplUC9XTVFTL1dKOU1hQWxiSXNjTkpFYXlwelhUNGZUVEti?=
 =?utf-8?B?b0VabXNCdElNaThHZUUwU3ZBQi9SM1hlbG9GQjZUakMzcnBaOHE1RmNGcnk3?=
 =?utf-8?B?Z0JkamNDOGRyWk5vdU5Qd3VldGFFb3pMQ1JZTTNlbXJKUUFPY0JGQjBzNVpU?=
 =?utf-8?B?SGJzUEdXSjk5bldMM0o0TG5MeVdwaEpHTWJDV1Ruc3I3SmdVVXF3aFNKQTFH?=
 =?utf-8?B?QWgzYzNiZzlHNWpieTIrY1JCbnk4NzRGWHhHdndIMHJBSjh4akluSG5zNU05?=
 =?utf-8?B?YW9GUFVKTHZyT05EM1Z4bG95VEJhV0NtNUNUUmNUMjJPNTJTS3l2UWxYL0sw?=
 =?utf-8?B?aHN0UFVxT3U4U1laYUpyVWl5bDFWeDhicWNJT1lEY0Q1VjRNNzI2WFNYSS9G?=
 =?utf-8?B?OHhyRTc5ZWVRNTRiMDkyV3dSYUk0K2FlMURJVDU5R0xocHh3V25xTzhwamhT?=
 =?utf-8?B?UG9xYVhIdzhsb2dzVnIzOGNLTGdZUzZwU2taM0pnUm5WdXR4WWVHSDVNSHZ6?=
 =?utf-8?B?TzlIT0szditRT2svQ0xiYXZCMkhUTUduQUVLelpNQzBKUFQ2S015dHhYSUt1?=
 =?utf-8?B?VGJxZ2t0NTZ0NXlNZ0xkdndWNDlsZzVGNU1lMC9vV1o1OWtScGR1aTdsam5r?=
 =?utf-8?B?U3I2d3A3SkMwcGNxZ3BUbVhEUkVjMTFjM0lJeFVQMlJ6YTIwRTdCZDU5R04r?=
 =?utf-8?B?MStMM1gzL3hndHZUN3hRTkk5SDlxbnQ2RFEra3ZGRCs0bDNyMlJPUzhQczVn?=
 =?utf-8?B?dFJKOWw0VEpHOXZFdUUrcWNQQ1ZTQVBRUXE1cFpLK0JvM1M0OXBMb1piMkh4?=
 =?utf-8?B?cWZHaUp0cnpvMW5lZ2dXNlFPNHdJYktTRzBCT0pwYjZCRFp4TUxpTzFSdTBF?=
 =?utf-8?B?OUZjei9QQnF1NUQzM1pzZEhVY1hiQXVzMzZ0b25CVzNpM1I5T1R0dWhvTTVK?=
 =?utf-8?B?M3ZIQnd1RWR0ZUlsOXVhT1hRMUo1OEhBOVpFMGlCTWZpRXdYcy9UeHhEWHNW?=
 =?utf-8?Q?kBNLFb?=
x-forefront-antispam-report: CIP:255.255.255.255; CTRY:; LANG:en; SCL:1; SRV:;
 IPV:NLI; SFV:NSPM; H:DM3PPF12B913643.namprd19.prod.outlook.com; PTR:; CAT:NONE;
 SFS:(13230040)(376014)(1800799024)(366016)(38070700021); DIR:OUT; SFP:1102; 
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0: =?utf-8?B?ZDhuTDJ0WE1mcUNKdFA1K3N4b2hvVWd3Sk02VlhlZ29SOXZacXUzaW1rblZs?=
 =?utf-8?B?Q1hGM2dnRTNtemc1aDdOTVRDOW92VzZadDVQMTJJa05Ga3RlZU1wclUzRkhk?=
 =?utf-8?B?OUhCWFFDM3lMR2pTNUJ2TlZYdWE0dVArYVRrR1BleHJqMThYcW5sQ0s1Z04r?=
 =?utf-8?B?RmZlTi9OU2R4cmh2aU9JR1BXQXVqR2RtTXNYVElKRnBjbHFjYUZYTWMyZDVz?=
 =?utf-8?B?RTZBRkdibDVleEgxRlZ0MlFxOFh5azVCamdhM2Q5aEd0SGtiRHZtUGdFMVNW?=
 =?utf-8?B?RDc2OEFpbVcxTnA4cjNSekxNakhUN1U4QXMyR3NBZzhJWjkrSktoSFFoNDJZ?=
 =?utf-8?B?TmVCNWVtRFRjTmF0NnpSRlE4V1VEa3l4SlNCUXB4OTJaZUQ0KzV3bmJNZWZv?=
 =?utf-8?B?czNOTGhSVmwzaHhJRWFQamZEdGdFNTNFbEJLYmdzSDZIdEdRWTFoUXU5S2Va?=
 =?utf-8?B?aGZtRmhpT1MwVXJoUVJxUS9IYU1vaUhmWEE1c042Q1BMYVBZVEpHMVFGdHI2?=
 =?utf-8?B?VmpJZjZKMkRQL1NIcFlyUmZtVFBWVFVtN3pKbUFnSVJJblIxdjhtOTFzSHlN?=
 =?utf-8?B?RWNpVHh1QTczL25ZN1BHRE1LeloxbzR5aWE4QmpDK2NhbmJYV2pwSGdjUHZq?=
 =?utf-8?B?clJBMXFoaUlkVW1HcXVhVlRhSzlNalNIN1N1cDFyK1pENHFSeTAwVEFsMkxR?=
 =?utf-8?B?SUMrY3BNSldFNUY0WW1ZcW9EUTA5OWZOcGZQMGl2TW9DSmNScEp0T1E4SlFm?=
 =?utf-8?B?Q0dhTVRlR2FuRW9GYS9LdVh2L3p5NzhtcjQ4R3NOb296a0gyQ2R5S0w5ZzI4?=
 =?utf-8?B?TG1rRTNscXRrZVlTNFZOQU5SNEdwVlp3NFdEOFZLb2xnMXBvRWJ1cFVodTFP?=
 =?utf-8?B?ODY1Zmt5bzdrREdFcjBSais5Ym5qVHdMWkxNajFncDQ5Z05oV2dGWno1bDFV?=
 =?utf-8?B?WWZhYzlIU3BQZ3hncHc4M3RkL2VWWXJsQ245T2RjVDlxcXUwREJxWTU1eDJL?=
 =?utf-8?B?VmxnSnI2VHp4WDl4Z3pDR3oyZkpSelZwVzN3d0FXNURXNk5vdU9CVUtNcUU1?=
 =?utf-8?B?SUxhelEySkQ0ZzFXcnRnUGpVVGFCMFdDN2crYTQ4aTNkYW5LSjBmZHdWQWdV?=
 =?utf-8?B?K1ZYTzZJY2xwdno2SjFMUUI0dnBldVZEZHBTWG9ROXFkUEI5VEZvVE9RbGFl?=
 =?utf-8?B?NlpKN2RMWjVYdjdhZ1dMcXAyWW1QS2lrOXdtK1FrUHdlbnc2YTdKVzdURDVw?=
 =?utf-8?B?RnZzeGlIZVpjbnU1MzNLOXlDMXNtc1ZzYkVURVA3YlFEZExvamtpcnBqWlkx?=
 =?utf-8?B?VmVtNUxQbmxhQjZGUEhtNmh1aFUwUk9rRXg4d3psbzJVajN3MXVuclBMWUdU?=
 =?utf-8?B?UjFUdmhGLzZ4Ykc3RVNhbkVsZWpaV2xqVUFla0FkV21qdGlQSHkxU2h1cUU0?=
 =?utf-8?B?QmtvU3hXYkpINlpqRTY2V1o3VVBpbFkwVlN6dWVkNUZZckRWMmpnN3RVa1Vp?=
 =?utf-8?B?ZUR3UWp2S01hVnVZRDBHZFBLSC8vMUFDU0ZnNzFEV3o1M1pwMllJMmZCZVZH?=
 =?utf-8?B?bFJLVjZmWkhmRTVsZmtuRjRGN1hDM0hONUUvVGZRaWlsdjN0b0M1bDVSRVVJ?=
 =?utf-8?B?a2w0cXkyaXpDRUVIb3NBUzVhWHN3d2VyRHZTd1FSdDB1b3lCQVlOa1VzaTIz?=
 =?utf-8?B?VVBWbDN1VGpZbFpDS3IzSFVNRWZkSW9ROWNYY090dXFIODBTYXI5SWFPdmpr?=
 =?utf-8?B?VE1HU1duYXhBaitJWVp0bWJQM3pNMkZqNkMzK2hqOHBpV0JGMFRoNmtjUUtM?=
 =?utf-8?B?elgvOVdReG9ac0lsT3p4NzB5MFc1QUcvbXdWaXprTTFVZGx1Z2JOcWlid0Fu?=
 =?utf-8?B?Y2ozWll3M2ZCTm5rNFdnblFWWSt5ZmxsVGhlb0Zxa0p4dVV5RVBxaDM1S2xV?=
 =?utf-8?B?YithZUhibFhiSDVGK2ZNUG1CTnFYWG5pRkFRdEw4UGE5QlNJSm1tdzFESDdN?=
 =?utf-8?B?eTJCanRQTTFsNWZMKzNRTFhvb0VhUGNud0gzK1lRbnpxOTYzNEk1a0U2Vzll?=
 =?utf-8?B?NG1vWUVPbUMrR3hGb1JFaDZSTXNrNnpmWGtKMWszMmFyaFhoUUxiY2dIZE5r?=
 =?utf-8?Q?K3GA/tJEYRJnII6HXMzMYggTN?=
Content-ID: <946312CC86F3C944B34140831B4E1D72@namprd19.prod.outlook.com>
MIME-Version: 1.0
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-0: 5i/YHeK6fiFq5BRv2iJ5+bWGxzKqCwreJaKNve41rS16cKqrAv4qQPhi9S6SXPbMMxjgBsMotf2LLC1CXajMDrrKp3bZY0veB1k/mbC0jYopeEdBNiVKu/VFuIybf1B+pRAKyz33XTGqLVlAxg/mRa/yHJDh+rSG7WSICK46WI+3T/4n4C8m9kxhZz2OS2qHGWZspQvwmwJEB95bqW4Z/piCVa0sYAb+9hIJoIE4lHsUZytdck4mhj50twR2kckAWeucmbxFuXkyEdAewsJv1O+wK/bX3/D875/A9++Y9nhb2UfDd7g714eoEJHxWanBccJ2w3EfkZJob5xJMjMGyxWw5N8axHooN+Htg38HMNCJWFevUoIc0uzDRCAxbrEfZNOGjHLlvcY0zZzbojNW0ThMkcWVMLj0MTLzxLYVL5+ZTzYvuUHQmIBQHG4FDj3Y7SuPTPqHIb4prNE5EMR9hWz1UGdPK1ErFONv0mDXgB6mU60RzKPBcbk67kqIK3iMeuCH5MJu9jx9cithlDn/wDuiQpvfqAMiAyvuF1XE+LmdYzipBIuONFXC7MMOvddurFwdTTvHqRVjzkByse51jzNfC2ZSv6VHKGQTsHraG3ssOOQswS39inwPnK9NxByjI+SRMWccbX1251fFAL7K6URzIoUzVOuOsLmh6UIxtFY=
X-OriginatorOrg: whamcloud.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: DM3PPF12B913643.namprd19.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 3a5b498a-c954-4843-16ee-08de1bf7f5d0
X-MS-Exchange-CrossTenant-originalarrivaltime: 04 Nov 2025 23:14:52.7541 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 753b6e26-6fd3-43e6-8248-3f1735d59bb4
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: oyDJ1BX7MysxlXFLCDpFoKumlI1VCLtRJL5e4jF35vA7+2V2QHsCKzWaSUWn2Yb/
X-MS-Exchange-Transport-CrossTenantHeadersStamped: PH0PR19MB5364
X-BESS-ID: 1762298096-104509-22014-24303-1
X-BESS-VER: 2019.1_20251103.1605
X-BESS-Apparent-Source-IP: 52.101.52.73
X-BESS-Parts: H4sIAAAAAAACA4uuVkqtKFGyUioBkjpK+cVKVoYGhsZAVgZQ0MwoJcXMIsXAJM
 XIODXNMs0wzdzSxNws0czcwszUItlCqTYWAJKzDqlBAAAA
X-BESS-Outbound-Spam-Score: 0.00
X-BESS-Outbound-Spam-Report: Code version 3.2,
 rules version 3.2.2.268713 [from 
 cloudscan23-134.us-east-2b.ess.aws.cudaops.com]
 Rule breakdown below
 pts rule name              description
 ---- ---------------------- --------------------------------
 0.00 BSF_BESS_OUTBOUND      META: BESS Outbound 
X-BESS-Outbound-Spam-Status: SCORE=0.00 using account:ESS124931 scores of
 KILL_LEVEL=7.0 tests=BSF_BESS_OUTBOUND
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
From: Oleg Drokin via lustre-devel <lustre-devel@lists.lustre.org>
Reply-To: Oleg Drokin <green@whamcloud.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

T24gVHVlLCAyMDI1LTExLTA0IGF0IDIzOjA3ICswMDAwLCBBbmRyZWFzIERpbGdlciB2aWEgbHVz
dHJlLWRldmVsDQp3cm90ZToNCj4gDQo+IElmIHdlIGNhbiBpbXBsZW1lbnQgYSBuby10cmFuc2Fj
dGlvbiBvc2QtdmZzLCB0aGF0IHdvdWxkIGV4cG9zZSBhDQo+IGxvdCBvZiBmbGV4aWJpbGl0eSBm
b3Igb3RoZXIgcmVhc29ucyBhcyB3ZWxsLiDCoFBvc3NpYmx5IHRoZSBvc2QtdmZzDQo+IGNvdWxk
DQo+IGltcGxlbWVudCBhIGpvdXJuYWwgb3Igb3RoZXIgbG9nZ2luZyBsYXllciBpbnRlcm5hbGx5
IHRvIG1ha2UgdXAgZm9yDQo+IGxhY2sgb2YgdHJhbnNhY3Rpb25zLCB3aGV0aGVyIGluaXRpYWxs
eSBvciBhdCBhIGxhdGVyIHN0YWdlPw0KDQpUaGF0J3MgYWN0dWFsbHkgYW4gaW50ZXJlc3Rpbmcg
aWRlYSwgYnV0IHByb2JhYmx5IG5vdCB2ZXJ5IHByYWN0aWNhbC4NClRoZSBqb3VybmFsIGl0c2Vs
ZiBpcyBwcm9iYWJseSBub3QgcmVhbGx5IGZlYXNpYmxlIHdpdGggVkZTIGFwaSBhbG9uZQ0KYmVj
YXVzZSB5b3UgbmVlZCB0byB0b3VjaCBqb3VybmFsIHRvZ2V0aGVyIHdpdGggd2hhdGV2ZXIgaXQg
eW91IGFyZQ0KbW9kaWZ5aW5nLCB1bmxlc3MgeW91IHVwZGF0ZSB0aGUgam91cm5hbCBmaXJzdCBh
bmQgdGhlbiBldmVyeXRoaW5nDQplbHNlLCBidXQgdGhhdCBpcyBsaWtlbHkgZ29pbmcgdG8gYmUg
c2xvdyBkdWUgdG8gYWxsIHRoZSBvdmVyaGVhZD8NClRoYXQncyBwcm9iYWJseSB3aHkgYWxsIHRo
ZSBqb3VybmFsaW5nIGZpbGVzeXN0ZW1zIGhpZGUgdGhlIGpvdXJuYWwNCmluc2lkZSB0aGVtc2Vs
dmVzIG91dCBvZiByZWFjaCBmb3IgdGhlIFZGUyBhcGkuDQpPZiBjb3Vyc2UgVkZTIGFwaSBjb3Vs
ZCBwcm9iYWJseSBiZSBleHRlbmRlZCBldmVudHVhbGx5IGlmIHRoZXJlJ3MgYQ0KZ29vZCBqdXN0
aWZpY2F0aW9uLCBidXQgd2hvIGtub3dzIGhvdyBsb25nIGl0J2xsIHRha2UgYW5kIGhvdyB0aGUg
ZmluYWwNCmFncmVlZCB1cG9uIGltcGxlbWVudGF0aW9uIHdvdWxkIGFjdHVhbGx5IGxvb2sgbGlr
ZS4NCg0KDQpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwps
dXN0cmUtZGV2ZWwgbWFpbGluZyBsaXN0Cmx1c3RyZS1kZXZlbEBsaXN0cy5sdXN0cmUub3JnCmh0
dHA6Ly9saXN0cy5sdXN0cmUub3JnL2xpc3RpbmZvLmNnaS9sdXN0cmUtZGV2ZWwtbHVzdHJlLm9y
Zwo=
