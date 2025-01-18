Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 11E34C02183
	for <lustre-devel@archiver.kernel.org>; Sat, 18 Jan 2025 03:17:12 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4YZhbn02YLz1xp6;
	Fri, 17 Jan 2025 19:17:08 -0800 (PST)
Received: from outbound-ip168b.ess.barracuda.com
 (outbound-ip168b.ess.barracuda.com [209.222.82.102])
 (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4YZhbb5gxhz1x2D
 for <lustre-devel@lists.lustre.org>; Fri, 17 Jan 2025 19:16:59 -0800 (PST)
Received: from NAM10-BN7-obe.outbound.protection.outlook.com
 (mail-bn7nam10lp2045.outbound.protection.outlook.com [104.47.70.45]) by
 mx-outbound42-195.us-east-2c.ess.aws.cudaops.com (version=TLSv1.2
 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
 Sat, 18 Jan 2025 03:16:56 +0000
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=SnuZts4jKmItt9YbC5yaaJCrSNDLGDNYbiXlwVoG49VwnYcrCwr9hQXrLBEjnSarxNJkE5IuEfF4Py1WSXaFUGNHEpccwMpTamCQpEMPfvU3q8W2yOgKiQ82M8yBrU5dHv3SqXbfHwbOMubXfHaaB497m2PJ2NHKf1y9n+s+8rZQSAA7rqMLIAjZaqwMa1ITyFsd30acpVwbWo5ABzHyz4UnSgYznk3IQcQ151tlAZIG/vC/6jFQ60AOhOrfH88+pX0+47GKv6IhDadIwMygd1iXUlb5JI9Qr1Mklx2spjFiARKwiul8XesGYwgMJ7UHaRR7/VUj8t67Yl3lxTpVrQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com; 
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=TtxRh5a1TWWekrLMZvEf8h4GTpYoON4Xi3OC0x3rt/M=;
 b=Alhm3raNM9sB4FzTl/CFc/gFmPZ6++goyL6ieQ4I38zYKnWNZGSLJiIrpLoiEYVsZVxE6czw1XhOxaMF1YkQDjwxX4pZ0ap/Nj2P8IlF7d1BrP0rTLOczTeUCq1KBVn48ui1Yng5lzbl6R7qFVrFlYnbohyLTraNNJ+wjmTRdt0jU6oxIqlUZ4KjHAvT5B8RPSw4R+nGVFUnNxnpg6XwvuFnyahDdjiFkFLgu5y6Ro7Pf56gn/jLuAHKpgoBcc61hzNtXVUO0opeYQGFvGxpfc93fVcdS7mNWIfHRhwtA0DHFNrjwW4Gssmctf7qqlvTAp/7r7Wz3hWob4QJu1y8GA==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=whamcloud.com; dmarc=pass action=none
 header.from=whamcloud.com; dkim=pass header.d=whamcloud.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=whamcloud.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=TtxRh5a1TWWekrLMZvEf8h4GTpYoON4Xi3OC0x3rt/M=;
 b=a/sBbetDhjyg5AB071/LXmEMhyFbkFqQvVHSMyLUZqg5WhXL5ifr1nASoCQqW+ZpiGL3C5pTsUjBIzLvWiIwF3SoAVY4rtem8/0zEnmpZKBA0pRFU1gA4GhptVmCPYHY2eZFh6UeANNwfSoq7aHrmbZA1223vLsujnwngUgNQfs=
Received: from SN7PR19MB6567.namprd19.prod.outlook.com (2603:10b6:806:26d::11)
 by SA1PR19MB8845.namprd19.prod.outlook.com (2603:10b6:806:45c::17)
 with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.8356.16; Sat, 18 Jan
 2025 03:16:53 +0000
Received: from SN7PR19MB6567.namprd19.prod.outlook.com
 ([fe80::db50:586b:7dda:cf04]) by SN7PR19MB6567.namprd19.prod.outlook.com
 ([fe80::db50:586b:7dda:cf04%6]) with mapi id 15.20.8356.014; Sat, 18 Jan 2025
 03:16:53 +0000
From: Oleg Drokin <green@whamcloud.com>
To: "timday@amazon.com" <timday@amazon.com>, "neilb@suse.de" <neilb@suse.de>
CC: "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>
Thread-Topic: [lustre-devel] [LSF/MM/BPF TOPIC] [DRAFT] Lustre client
 upstreaming
Thread-Index: AQHbaF06daQEbe3e/kelMir67rT0hbMbs8GAgAAqWwA=
Date: Sat, 18 Jan 2025 03:16:53 +0000
Message-ID: <785a407c987a57ddf6bbfbed05230981af66cd26.camel@whamcloud.com>
References: <3139EEF5-91BF-4F8E-A112-1D66455AE3D2@amazon.com>
 <173716111777.22054.8452560203667698532@noble.neil.brown.name>
In-Reply-To: <173716111777.22054.8452560203667698532@noble.neil.brown.name>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=whamcloud.com;
x-ms-publictraffictype: Email
x-ms-traffictypediagnostic: SN7PR19MB6567:EE_|SA1PR19MB8845:EE_
x-ms-office365-filtering-correlation-id: 243d6666-90cb-48d9-aea8-08dd376e8e60
x-ms-exchange-senderadcheck: 1
x-ms-exchange-antispam-relay: 0
x-microsoft-antispam: BCL:0; ARA:13230040|366016|1800799024|376014|38070700018;
x-microsoft-antispam-message-info: =?utf-8?B?anJUMVdtejgzNDd1THNWbUdWT3d5UEVBM2pHZjdIdkxSODRXbEU4SnB6MitC?=
 =?utf-8?B?UzZNUkFxam5Vekp1eGxWODNLY0Y1YmNNcXRvVWJxU1BIdWxUdjQzamIvVGVw?=
 =?utf-8?B?YktEeWlSbTRTdFZDNTV1NW1uVjloczNTV1BRc29kVVBLRUREaGw3VHZBTjVR?=
 =?utf-8?B?Zlg4Rk5Qck5RaWRCcmYzVXZLd1pSaHFyL0YwTU5QdlZNUUUwaTExNjlDeFRR?=
 =?utf-8?B?L3N3bVMrdGx3UGoycXhGTmJVWHJTanpWNjV0Nm9XZXZQMFIrR0dtTmNETzVz?=
 =?utf-8?B?QllPeUN3blVpb1BYbk82T0laUUZlOGdxN2Uwd3p1eDB4cVA3VTRUOVlxMGRT?=
 =?utf-8?B?bkN2ckxmUFc4V2dEc2lrWVVPRUpHRzhYY1B4anErUE5IVmNzbnFCaUk1emhB?=
 =?utf-8?B?Z3RqaUtPR3U0ODM5MmF2NU90Ym5zV0UyZTJZVzYzMzJwSE5UVTdkV1lBVm1k?=
 =?utf-8?B?eml6RnJuN3FEQ0FXY2ViSHFsNXFodngzNG9CM1VOTW0wMkNGTG1CRG5tZmh4?=
 =?utf-8?B?WjM1S2JvYUlML2V6dHB5L29MNGZLYk5PWjJOSHNjdUs0aFdlTHVEYWwrQytn?=
 =?utf-8?B?RkpsWkhGY2ZTRVFmL2FWaDYyK1gzRHBDZTJGbTM3alM5ak5temp5bk5MU1o3?=
 =?utf-8?B?R1Z1djJOZ3NHS25YblM4STdtQjQ2TTRpL2VvbzN5Sm5aM2VMaHFEcWF5SmRE?=
 =?utf-8?B?YThGR0hGWlhmZ0UwaXRnY2JScGxIUDl0VmhpbUdVeHNmajZvWGRRbFd2VW56?=
 =?utf-8?B?K3VCMy9lNjhFM2JoMlg1MmhNeEFSdFROQ1VJNENEU3dXbUdxR0w3NHZIWGtq?=
 =?utf-8?B?WjdudFlZamVPN0JhcDhHRGF2dnBmYjkrcEltSTYzbUZTdkl2T1BuTUovY2tk?=
 =?utf-8?B?M2N5QnNYcHEvYnlZMEhpQlBsR0RNTlo2Y0lUdDJweEhRTXd2clNsMjNjNzhP?=
 =?utf-8?B?QTdxY3pleEhCYnlYUTlWdFVjTUxrOXcvUllCWk9jdW05THl1dko0OFYraWtJ?=
 =?utf-8?B?VmhUamNjNldoWjZWS3hmU1A1RmcvcFliVU9RRmVOWWNyek9KUnR1aHh1MHJV?=
 =?utf-8?B?WG0vVUtIQUZkazJwMk1lTFlXVGF0OGFtNDlUS3YzN3cyZklQMGg4VmNaWGps?=
 =?utf-8?B?Nm00U2VmTjJSTkY3WHFnamkvUzBGOG9pVTVVajBXcE9ReXBKWHBkRmprVEc4?=
 =?utf-8?B?Y0hXczFNd0Vjb3FkT0p6eHhHQWFHRzBLdEtDSUlhWXJ3M0k2SzZJVzloTkdN?=
 =?utf-8?B?RGNDM2NUbmFNY1h1eHBwQkcvYWNOalI2QWN1NzNscXRUK1Zrajd4OGhBNktP?=
 =?utf-8?B?dE12aUpxN0hxZHQ4NzFVNFh3ZlYxWGZZODMrUlJNZEorYVZXSDQ3R3cwSEZw?=
 =?utf-8?B?d2JFRkRSYVdsaDNTQlE3S2tEMHhXMjVHMXJwVldhUjUyWm1IWlNoeDF0cnpY?=
 =?utf-8?B?allycS9kcHByZGF6SmVxSzBpb1ZNcUtSeUtRQXA4L09CenlKKzBtb3pIbUZv?=
 =?utf-8?B?aE90eFQyUFNOckRFRU5ITFcyNXpMKy9WNEF4V3JrZS94T3E4YUUrR2l5aFpv?=
 =?utf-8?B?dVhNelFMeEw4UVc3OFVjUm4ybWd6dEZWMGZKcGVaMVJjUjlpb3VaNVFwUGdv?=
 =?utf-8?B?aW9vd0NqckNiL2p5UXZyMHErMFhmZXZxOE9YOFA2VitBSEdhVTVGcFcwdHdC?=
 =?utf-8?B?cVpWMnc5aXBkWXgrdlFuVStVSDRmL0xiWEtESjBFNFRaUVJJM2VVcWxkNkwx?=
 =?utf-8?B?MEk2VUJTa29EVkVnZWJtYmZiWktPNFJ6MUpRZWMxRFVnWXdlbXpJSzE0dG5U?=
 =?utf-8?B?U1ZQdGp5TTJqUGtSOEx6VDBNY0lMUjYwYTFKSXJCeU9hVjB4T1hsZm5sZlNn?=
 =?utf-8?B?TTZDMUt4Z2JiWWpJSmdnM0s1OS83ZUJZQlhFb1IvcS93L2hrWnFEM3NsdDVM?=
 =?utf-8?Q?nxQaZONBLCeI7rqHnffFE9Wzo80R0L5d?=
x-forefront-antispam-report: CIP:255.255.255.255; CTRY:; LANG:en; SCL:1; SRV:;
 IPV:NLI; SFV:NSPM; H:SN7PR19MB6567.namprd19.prod.outlook.com; PTR:; CAT:NONE;
 SFS:(13230040)(366016)(1800799024)(376014)(38070700018); DIR:OUT; SFP:1102; 
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0: =?utf-8?B?eE5nbCtHbTB1Vy9RblpXRXJIWit0WmVsUG9UNFNkQkk2bDkwMGtMYUVKYXdW?=
 =?utf-8?B?S3lpRFdTSUhYa0lMcVdMRjllTWE2cGN5am1tbU9yaUd3RDVIaEtHOHdackY3?=
 =?utf-8?B?eTlBRlg0MHNHajJjT2NKYnBQY3hDa08rTDZ2OUVjRHFNSWY1VkdUTDFSOXFl?=
 =?utf-8?B?QThBNmVmbzhPSlczTFViUlVyeThsWWtnbzVDRUQ2ekpYSXJvNGdvNTc1Umh2?=
 =?utf-8?B?K2pwNmFzTi9yak1QalhyWHJOSWVZaTR1NTlFbGh0eDJZeTJTNXRVUCtwY1Jv?=
 =?utf-8?B?QUMwVlp1ejNqOVBEUEpnS25NK3Z4K21hVjNDVUswYk5wUWtGRStpNEl0V25U?=
 =?utf-8?B?S203aG9TL3VxU0tJRmgwR2N1VGlWbGJRTUxSd2ZnRHhhNUNTa09JNUxWQmxo?=
 =?utf-8?B?cTdKV2F4RndDU0UzYk5RZ1p1SGk2bnlpNlZTM3p1WHJmQVVMWGx2NC9TK24y?=
 =?utf-8?B?eVRqSEpVR3hpZGM3dlVwT01VK08rSmQ3WTl1TXd6dmJzcjRpQVdaK3RweWJl?=
 =?utf-8?B?a2ZCRnptSHBkemFzSlB6ZzNsVHNpNzJBTE40Vk4zc2dFbnRNMlEyNlVVYUgz?=
 =?utf-8?B?TmRLZEkzTXpuM1pCTk5wNUw5VTViWlg0T3JKbFo3YXJlZEl3NmdpNTk4ZXVr?=
 =?utf-8?B?VkJuNGdzS05oQmNOeHkwSEtpQ3piQ2dFNHJjYzFOWjRiYi9qSWRLbXFHS2d2?=
 =?utf-8?B?YlNoNVhMK1pNdnU0OHlIcU8xT1dPSnVEQXhEODRSWXp5dGwrZmJoRjVLV3NO?=
 =?utf-8?B?MnFxL1BuQ3BFekhkQXhTSmtJMHNhdmJzaGpvejJJcmt3R0p4UUNNZU9TU0t0?=
 =?utf-8?B?RDl1TDB3QTJzSFpIeUxsNm11ZklwbHRNYjIyUEpXS1J4bVZZeU9tbGg5Ym0z?=
 =?utf-8?B?cWcwUUJRRWhXbUhFY1FuT1hVU2Z4VzYzam9EVTNiY3NkU1lGM08wcHNGaTE2?=
 =?utf-8?B?cU9HUHNNamsvb0ZGWXRvaG1PUTdmdHN5UFpUZ2VOY3hxbkk1eDRKQ2NXZ3BK?=
 =?utf-8?B?VGZSN1MzTVRxTmdBTGI0Yzd2UExXaE5ySWNNL1R3aGhBNUZIZVB4cHd3My9O?=
 =?utf-8?B?UXYxZW9Pdm5UZTVqcEsxUmU4bG9XQ3QvOUduSDFXa2hLUDdaeVlUaW9qY3lX?=
 =?utf-8?B?TDdsRzMydVB3aWNLYTk5QzZ1ZWxFUU5JaW1ENVZkekpZZjhCeGFjR205RG1K?=
 =?utf-8?B?THNhelh3YXJKM1lPblJlZHN5amlpamRQY3lTS3A3bzlVV0N3MVk2L0UrOXAr?=
 =?utf-8?B?Vkl5SjdKak41aUFNYzhHS1JpWjRLYzhUNGQxN2Yvd0VxTkpEQm84cDIzMjhR?=
 =?utf-8?B?N25ZZHhsZ0dwUTJnYmd6TVVNMkxjVUFKaTZOTXcvVU9xZDBHTkd2REdhVGxL?=
 =?utf-8?B?RFQxOFZkS0E0bEt0cWhoODRJT3lEcGZwV3czM0pUdyt2UTdjN05iYUtUOWRP?=
 =?utf-8?B?dmYwYXpId2JsUjdPSHVmYzZqa1d2bW1SVS9qSXQzanN1T1NCQkl3ZGNqMXpi?=
 =?utf-8?B?Wlo0L0k0ZmJjN2FOcW5kaktRSDlQUTdRWG1lclhwaVQzVkt3c0pqd3lva09L?=
 =?utf-8?B?QTN0Z08rZjhabE0rOHRkcXprR1FJN2xKcEhZU1dqUnhYQ0N3cW9Sa1ppbTVM?=
 =?utf-8?B?b3ZqUnBnb1F2K1Q1V05XZ0c3NWlCOStLbFJ6QWdBdmFwK3lYWVZ4SlA1cEZC?=
 =?utf-8?B?Y1o0bkVKMURXTWRwY3NhNitJYVRyZlhCSURZcERvSjJZRlZmSy9OQ2hnZFNm?=
 =?utf-8?B?ZXcrTVJtU3NYWHYyZCtzeEc4SEZwRVVjUVZublFWa2p1b2lDak1ZS3lydHYv?=
 =?utf-8?B?Rmp2cXVIRy94Ny8xOFRIeFhBcU1EMitCeFJpTUl3WW5mTFA2dlJPcFhjaHRl?=
 =?utf-8?B?WDNwUVdkc21Sd09TaSswckpLbFZnaFlrRTRMdzRRMGtDN3l5V21BWnErbWtM?=
 =?utf-8?B?L2wzdU05cXY1WFJZWUIvU2dFdHVNSkV2OHdYZU5kcnBnRjJlMmd0Q3E1N1ZS?=
 =?utf-8?B?N3JKM0pTZW9CcjUzc2ovRXN0bGN3VXk3elNHdWRIK1lkUURoQkhTbmZ4emtx?=
 =?utf-8?B?VmJuSW9VbGIyT2hzMTljYkVteTZ5RnB0U0NoVkEybWFHMlI5S2hWRXBNS2Zr?=
 =?utf-8?Q?FqRloqqFCrxZMnqUKhbD1AWao?=
Content-ID: <9EE1FF40F376854088B2C5FA652AEADC@namprd19.prod.outlook.com>
MIME-Version: 1.0
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-0: +uC9kUWpZi9zLLnA2EM4sy7dARsSvtp0pHE/0bQJtevR7IT5y6E/xPXb2OzXZll0GYCqKLa3+Edxfth5SThRYJDvyZyWzHxUCGmTZv1pkHxzgVpsmyEmNphTWNrHG5EcB1LF7loENyJQ/OGwv1vLPs+12Y7BXNLaSVX59tcfwHd45a3j4+EQXxK1t4sKRISsl7vWCu74yG9ZrtXgbKeoL3/+aiLASZMT0zGTFx/uvBv0ChuGrWb1RoRNkOyCCncwm1WkIfmBCYFbedDbaqxoE+Mn6Lfa5GjpGYw2M1dLgzji6vyFhARzUKgCa8yqqnH8PxTw2lyFsTenGQMmcX8q1U7Ogq9BXU+h11gJcyWLPjZ4Et/VgMr4A7ZV8m/luP5FR/k4c6OZHQd9mntOXR+Cbscr6ZBi7hY6l8vqmxDPFL7lTe3JvF4h7WxH9srFUNV9kzsE5QYacR4/R9IOIHsX+Jp6jtwsH9uBQLOblCqQ+UDv+QkM+XNJFRjfplDj7y6EAzHuEbv0nJwdFN7kBtCwBGjYVc/mfLbIb6N/xUAY9tlKUaB3ziFEEO/KZwwNWR+/hhLQkcOrV5kuYLZeoWgR0JASlzYQTsLkbhUw8z7wZW75LLRBUQYf7ghmlgO8xcIoGgCi3dkbKX7GmiN9oVafJ8Bj004sTJeplWB9WSs/D00=
X-OriginatorOrg: whamcloud.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: SN7PR19MB6567.namprd19.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 243d6666-90cb-48d9-aea8-08dd376e8e60
X-MS-Exchange-CrossTenant-originalarrivaltime: 18 Jan 2025 03:16:53.0514 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 753b6e26-6fd3-43e6-8248-3f1735d59bb4
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: DNlnbVLEsBEAU0L4f4CAP1ncpcvt/YMVh4/+EXXSq4XwY+Ad3ILCEwBqdmCulvs0
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SA1PR19MB8845
X-BESS-ID: 1737170215-110947-17278-35606-1
X-BESS-VER: 2019.1_20250117.1903
X-BESS-Apparent-Source-IP: 104.47.70.45
X-BESS-Parts: H4sIAAAAAAACA4uuVkqtKFGyUioBkjpK+cVKVsYm5pZAVgZQ0CjJJNHI3Dwp0c
 AsOcXIOMUkNSU5ycjcLMU42TQl1SJNqTYWAJ3VjkdBAAAA
X-BESS-Outbound-Spam-Score: 0.00
X-BESS-Outbound-Spam-Report: Code version 3.2,
 rules version 3.2.2.261886 [from 
 cloudscan14-43.us-east-2a.ess.aws.cudaops.com]
 Rule breakdown below
 pts rule name              description
 ---- ---------------------- --------------------------------
 0.00 BSF_BESS_OUTBOUND      META: BESS Outbound 
X-BESS-Outbound-Spam-Status: SCORE=0.00 using account:ESS124931 scores of
 KILL_LEVEL=7.0 tests=BSF_BESS_OUTBOUND
X-BESS-BRTS-Status: 1
Subject: Re: [lustre-devel] [LSF/MM/BPF TOPIC] [DRAFT] Lustre client
 upstreaming
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
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

T24gU2F0LCAyMDI1LTAxLTE4IGF0IDExOjQ1ICsxMTAwLCBOZWlsQnJvd24gd3JvdGU6DQo+IFdl
IG5lZWQgdG8gZGVtb25zdHJhdGUgYSBwcm9jZXNzIGZvciwgYW5kIGNvbW1pdG1lbnQgdG8sIG1v
dmluZyBhd2F5DQo+IGZyb20gdGhlIGR1YWwtdHJlZSBtb2RlbC7CoCBXZSBuZWVkIHBhdGNoZXMg
dG8gdGhvc2UgcGFydHMgb2YgTHVzdHJlDQo+IHRoYXQgYXJlIHVwc3RyZWFtIHRvIGxhbmQgaW4g
dXBzdHJlYW0gZmlyc3QgKG1vc3RseSkuDQoNCkkgdGhpbmsgdGhpcyBpcyBub3QgdmVyeSByZWFs
aXN0aWMuDQpMYXJnZSBjaHVuayAoMTAwJT8pIG9mIHVzZXJzIGRvIG5vdCBydW4gbm90IG9ubHkg
dGhlIGxhdGVzdCBrZXJuZWwNCnJlbGVhc2UsIHRoZXkgZG9uJ3QgcnVuIHRoZSBsYXRlc3QgTFRT
IGVpdGhlci4NCg0KV2hlbiB3ZSB3ZXJlIGluIHN0YWdpbmcgbGFzdCB0aGlzIG1hbmlmZXN0ZWQg
aW4gcmFuZG9tIHBhdGNoZXMgYmVpbmcNCmxhbmRlZCBhbmQgYnJlYWtpbmcgdGhlIGNsaWVudCBj
b21wbGV0ZWx5IGFuZCBub2JvZHkgbm90aWNpbmcgZm9yDQptb250aHMuDQoNCk9mIGNvdXJzZSBz
b21lIGF1dG9tYXRpYyBpbmZyYXN0cnVjdHVyZSBjb3VsZCBiZSBidWlsdCB1cCB0byBtYWtlIGl0
DQpzb21ld2hhdCBiZXR0ZXIsIGJ1dCBpdCBkb2VzIG5vdCByZW1vdmUgdGhlIHByb2JsZW0gb2Yg
Im5vYm9keSB3b3VsZA0KcnVuIHRoaXMgbWFpbmxpbmUgdHJlZSIsIEkgYW0gYWZyYWlkLg0KDQpJ
dCBkb2VzIG5vdCBoZXAgdGhhdCB0aGVyZSBhcmUgd2hhdCAzPyA0PyB0cmVlcywgbm90ICJkdWFs
LXRyZWUiIGJ5IGFueQ0Kc3RyZXRjaCBvZiBpbWFnaW5hdGlvbi4NCg0KVGhlcmUncyBERE4vd2hh
bWNsb3VkICh0aGF0J3MgcmVhbGx5IHR3byB0cmVlcyksIHRoZXJlJ3MgSFBFLCBMTE5MDQprZWVw
cyB0aGVpciBmb3JrIHN0aWxsIEkgdGhpbmsgKHRob3VnaHQgaXQncyBtb3N0bHkgYmFja3BvcnRz
PykuIFRoZXJlDQphcmUgbGlrZWx5IG90aGVycyBJIGFtIGxlc3MgZXhwb3NlZCB0by4NCg0KU3Vy
ZSwgb25seSBvbmUgb2YgdGhvc2UgdHJlZXMgaXMgY29uc2lkZXJlZCAiY29tbXVuaXR5IEx1c3Ry
ZSIsIGJ1dCBpZg0KaXQgd2lsbCBkZXRhY2ggdG9vIG11Y2ggZnJvbSB3aGF0IG1ham9yaXR5IG9m
IGRldmVsb3BlcnMgcmVhbGx5IHJ1bnMNCmFuZCBnZXRzIHBhaWQgdG8gZG8gLSB0aGUgImNvbW11
bml0eSBMdXN0cmUiIGNvbnRyaWJ1dGlvbnMgcHJvYmFibHkNCndvdWxkIGRpbWluaXNoIGdyZWF0
bHksIEkgYW0gYWZyYWlkLg0KDQpUaGUgcGFzdCBzaXR1YXRpb24gb2YgIm9oLCB0aGlzIG5ldyBl
bnRlcnByaXNlIGxpbnV4IGNvbWVzIHdpdGggYQ0KY29tbXVuaXR5IGx1c3RyZSB2ZXJzaW9uLCBz
byB0aGUgZmlyc3Qgc3RlcCB0byBnZXQgc29tZXRoaW5nIHVzYWJsZSBpcw0KdG8gcmlwIGl0IGVu
dGlyZWx5IG9mZiBhbmQgdGhlbiBhcHBseSB0aGUgbmV3IGdvb2QgdmVyc2lvbiIgaXMgbm90DQpl
eGFjdGx5IGRlc2lyYWJsZSBlaXRoZXIgSSBhbSBhZnJhaWQuDQoNCkFuZCBzb2x2aW5nIHRoaXMg
cHJvYmxlbSBpcyBtb3N0bHkgb3V0c2lkZSBvZiBoYW5kcyBvZiBpbmRpdmlkdWFsDQpkZXZlbG9w
ZXJzIG5vIG1hdHRlciBob3cgY29vbCBJIHRoaW5rIGl0IHdvdWxkIGJlIHRvIGFjdHVhbGx5IGhh
dmUgYW4NCnVwIHRvIGRhdGUgTHVzdHJlIGluIHRoZSBtYWlubGluZSBsaW51eCBrZXJuZWwuDQoN
Cj4gVGhhdCBtZWFucyB3ZSBuZWVkIHRoZSBtb2RlbCBmb3Igc3VwcG9ydGluZyBvbGRlciBrZXJu
ZWxzIHRvIGJlDQo+IGNvbXBsZXRlbHkNCj4gYmFzZWQgb24gbGliY2ZzIGhvbGRpbmcgY29tcGF0
aWJpbGl0eSBjb2RlIHdpdGggbm8ga2VybmVsLXZlcnNpb24NCj4gI2lmZGVmcyBpbiB0aGUgY29k
ZS4NCj4gDQo+IFdlIG5lZWQgYSBzdHJvbmcgc2VwYXJhdGlvbiBiZXR3ZWVuIHNlcnZlciBhbmQg
Y2xpZW50IHNvIHRoYXQgd2UgY2FuDQo+IGp1c3RpZnkgZXZlcnl0aGluZyB0aGF0IGdvZXMgdXBz
dHJlYW0gYXMgYmVpbmcgdG8gc3VwcG9ydCB0aGUgY2xpZW50LA0KPiBhbmQgd2hlbiB3ZSBhZGQg
c2VydmVyIHN1cHBvcnQgdG8gdGhhdCwgaXQganVzdCBhZGRzIGZpbGVzLsKgIFBvc3NpYmx5DQo+
IHdlDQo+IGNvdWxkIHBhdGNoIGEgZmV3IGZpbGVzIHRvIGFkZCBzZXJ2ZXIgc3VwcG9ydCwgYnV0
IHdlIG5lZWQgdG8NCj4gbWFpbnRhaW4NCj4gdGhvc2UgYXMgcGF0Y2hlcywgbm90IGFzIGFsdGVy
bmF0ZSB2ZXJzaW9ucyBvZiB1cHN0cmVhbSBmaWxlcy4NCj4gDQo+IFdlIG5lZWQgdG8gcXVpY2ts
eSByZWFjaCBhIHBvaW50IHdoZXJlIGEgbHVzdHJlIHJlbGVhc2UgaXM6DQo+IA0KPiDCoC0gYSB2
ZXJiYXRpbSBjb3B5IG9mIHJlbGV2YW50IGZpbGVzIGZyb20gYSBjaG9zZW4gdXBzdHJlYW0gcmVs
ZWFzZSwNCj4gwqDCoCBvciBqdXN0IGEgZGVwZW5kZW5jeSBvbiB0aGF0IGtlcm5lbCBzb3VyY2Uu
DQo+IMKgLSBhIGJ1bmNoIG9mIGV4dHJhIGZpbGVzIHRoYXQgbWlnaHQgb25lIGRheSBnbyB1cHN0
cmVhbTogc2VydmVyIGNvZGUNCj4gwqDCoCBhbmQgTE5ldCBwcm90b2NvbCBjb2RlDQo+IMKgLSBh
ICpmZXcqIHBhdGNoZXMgdG8gaW50ZWdyYXRlIHRoYXQgY29kZQ0KPiDCoC0gc29tZSBudW1iZXIg
b2YgcGF0Y2hlcyB3aGljaCBoYXZlIHNpbmNlIGdvbmUgdXBzdHJlYW0gLSBidWdmaXhlcw0KPiBl
dGMuDQo+IMKgLSBsaWJjZnMgd2hpY2ggY29udGFpbnMgYSBjb21wYXQgbGF5ZXIgZm9yIG9sZGVy
IGtlcm5lbHMuDQo+IMKgLSB1c2VyLXNwYWNlIGNvZGUsIGRvY3VtZW50YXRpb24sIHRlc3Qgc2Ny
aXB0cywgZXRjIGZvciB3aGljaCB0aGVyZQ0KPiDCoMKgIGlzIG5vIGV4cGVjdGF0aW9uIG9mIHVw
c3RyZWFtaW5nIHRvIGxpbnV4IGtlcm5lbC4NCg0KQWxsIHRoZXNlIHNvdW5kIGxpa2UgYW4gYXdm
dWwgbG90IG9mIGRlZGljYXRlZCBkZXZlbG9wZXItaG91cnMuDQoNCj4gTWF5YmUgdGhlIHF1ZXN0
aW9uIGZvciBMU0YgaXMgOiB3aGF0IGlzIGEgc3VmZmljaWVudCBkZW1vbnN0cmF0aW9uIG9mDQo+
IGNvbW1pdG1lbnQ/DQo+IA0KPiBUaGUgYmlnIHF1ZXN0aW9uIGZvciB1cyBpcyA6IGhvdyBhcmUg
d2UgZ29pbmcgdG8gdHJhbnNpdGlvbiBvdXINCj4gaW5mcmFzdHJ1Y3R1cmUgdG8gdGhpcyBtb2Rl
bD8NCg0KYW5kIHdobyB3b3VsZCBwYXkgZm9yIGl0Lg0KDQpUaGlzIGluIHRoZSBlbmQgd2FzIHRo
ZSBkb3duZmFsbCBvZiB0aGUgcHJldmlvdXMgYXR0ZW1wdC4gVGhlcmUgbmV2ZXINCndhcyBhbnkg
c2VyaW91cyBmdW5kaW5nIGJlaGluZCB0aGUgZWZmb3J0IHNvIGl0IGJlY2FtZSBhbiBhZnRlcnRo
b3VnaHQNCmZvciBtb3N0Lg0KDQo+IEl0IHdvdWxkIGJlIG5pY2UgdG8gaGF2ZSBhIHRpbWVsaW5l
IGZvciBnZXR0aW5nIHRoZSBzZWNvbmQgYW5kIHRoaXJkDQo+IGJ1bGxldCBwb2ludHMgZG93biB0
byB6ZXJvLsKgIE9idmlvdXNseSBpdCB3b3VsZCBiZSBhc3BpcmF0aW9uYWwgYXQNCj4gYmVzdCwN
Cj4gYnV0IGEgbGlzdCBvZiBzdGVwcyBjb3VsZCBiZSB1c2VmdWwuDQo+IA0KPiBUaGFua3MsDQo+
IE5laWxCcm93bg0KPiANCg0KQnllLA0KICAgT2xlZw0KDQpfX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fXwpsdXN0cmUtZGV2ZWwgbWFpbGluZyBsaXN0Cmx1c3Ry
ZS1kZXZlbEBsaXN0cy5sdXN0cmUub3JnCmh0dHA6Ly9saXN0cy5sdXN0cmUub3JnL2xpc3RpbmZv
LmNnaS9sdXN0cmUtZGV2ZWwtbHVzdHJlLm9yZwo=
