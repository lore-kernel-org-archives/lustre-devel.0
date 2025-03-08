Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 8DF8EC282EC
	for <lustre-devel@archiver.kernel.org>; Sat,  8 Mar 2025 05:36:48 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Z8sNF6J33z1xFD;
	Fri, 07 Mar 2025 21:36:45 -0800 (PST)
Received: from outbound-ip191a.ess.barracuda.com
 (outbound-ip191a.ess.barracuda.com [209.222.82.58])
 (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Z8sN05y09z1wVt
 for <lustre-devel@lists.lustre.org>; Fri, 07 Mar 2025 21:36:32 -0800 (PST)
Received: from NAM12-BN8-obe.outbound.protection.outlook.com
 (mail-bn8nam12lp2175.outbound.protection.outlook.com [104.47.55.175]) by
 mx-outbound42-86.us-east-2c.ess.aws.cudaops.com (version=TLSv1.2
 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
 Sat, 08 Mar 2025 05:36:28 +0000
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=aZXWVHCf9uK2xwRKywrj8kQRQm727xriwJgDB3vum/K+ZqP7MZoBgwyOiz4Uj65lkdbXPfnmyrNVzWltYkyPwpGbDvYD6kP88joW1PNt8s3RfAj5MfN6aWDHTnT6w8JtReNAcq4SdCeIENEsQmcb2oz7gHfd1sG1g8xIcau/kYRd71I1n5e+VFXIjLHTgqVoXJDB+koSNVrbbfHGXsDBZzwQVQa0B2jJ1e1uJvidLDDoO8VTyxe+Bsk2QQSY/9nMqDKwQEN9Wpb44MCfd+2gg1lLuPhxToIQ6MPlrLyP34jWmuImweWypvQ+n74HesSCTHc+VxNgRponIqSv5PBPrw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com; 
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=J6MxnWi3MdFpI6OYClmFn1vXKV5TVQIigHh0lqKgAVw=;
 b=yzxuytwmaKrwYc/9Nk2ELBP4GdrQyker7KSxQOzY5wlx4RIszJdHYzIYXGBZ8LT3aP4mIi+w40iqy6mdeM9I3bDKzTSBiYTikE9oogIzJjVS5SWRGXhej9TLB6Xez8peaVmkmFl+FN/j59NO6nixS26B4K5eECfQNtsNsJ8TrsuEULdPk/NOMiLR8y/spR+MAgm/nZWVPs43VTTdtkLhpLcjNx9FT9vjmYMcpKT4EWpsu+LFKX3aYqM7h+j2cGNevWgPRJbtmEWgeTkdmOaRec42GrOKctTGy7okSLCvj1gkRjJPBgBMEbdsfaKJgEDHKTu4PuRi2vbFkWDxpHrmkQ==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=ddn.com; dmarc=pass action=none header.from=ddn.com; dkim=pass
 header.d=ddn.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ddn.com; s=selector2; 
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=J6MxnWi3MdFpI6OYClmFn1vXKV5TVQIigHh0lqKgAVw=;
 b=kWum+qNC8rChO9TX8irZSIyNVn7EAX9lv5AA79/z/pqR6+GJ+s3JI7BFJ2UN+8hLuUU1z3+a5Fdkmu60hLetF2hCnSd6veKqMG6zHy1Pc8Grgv9EK4TyxXzQ9EfcHXFVVLsGZwbeSU5LIZBY4N1miAhuNz6YRhd23FNHcjUVT8Q=
Received: from MW4PR19MB5630.namprd19.prod.outlook.com (2603:10b6:303:189::12)
 by SJ0PR19MB4477.namprd19.prod.outlook.com (2603:10b6:a03:278::12)
 with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.8511.19; Sat, 8 Mar
 2025 05:36:24 +0000
Received: from MW4PR19MB5630.namprd19.prod.outlook.com
 ([fe80::92fd:9b94:d9cd:81d2]) by MW4PR19MB5630.namprd19.prod.outlook.com
 ([fe80::92fd:9b94:d9cd:81d2%7]) with mapi id 15.20.8511.017; Sat, 8 Mar 2025
 05:36:23 +0000
From: Andreas Dilger <adilger@ddn.com>
To: Gian-Carlo Defazio <defazio1@llnl.gov>
CC: "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>
Thread-Topic: [lustre-devel] prevent lustre from using specific ports for
 socket connections
Thread-Index: AQHbjuGD40YijsJvgUqCehz3IkhwsbNouj0A
Date: Sat, 8 Mar 2025 05:36:23 +0000
Message-ID: <773F80A9-9357-4297-BC8B-B61477B25360@ddn.com>
References: <SJ0PR09MB638165AB4F27BA6F6F65BD2EE3CA2@SJ0PR09MB6381.namprd09.prod.outlook.com>
In-Reply-To: <SJ0PR09MB638165AB4F27BA6F6F65BD2EE3CA2@SJ0PR09MB6381.namprd09.prod.outlook.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=ddn.com;
x-ms-publictraffictype: Email
x-ms-traffictypediagnostic: MW4PR19MB5630:EE_|SJ0PR19MB4477:EE_
x-ms-office365-filtering-correlation-id: 28b6fe1f-60e9-4a60-db24-08dd5e0329e8
x-ms-exchange-senderadcheck: 1
x-ms-exchange-antispam-relay: 0
x-microsoft-antispam: BCL:0;
 ARA:13230040|376014|1800799024|366016|38070700018|7053199007|8096899003; 
x-microsoft-antispam-message-info: =?utf-8?B?ZlBNemtrV1A2czVJdk5XbFozdkVFcWJheW5UTkw4dVVIcVJ4bEdnSkV3UHda?=
 =?utf-8?B?MHUydjBmR0xyVXRidHppbmJyZE5GOXNQSGtYREFOSDlCRjRhRFkrdTNsOEZS?=
 =?utf-8?B?RHhEa2tlUVpzMnhWVnBORXR4VVlPZmVVejFXYlZXT1ZFb1l1NWFob2FieHpi?=
 =?utf-8?B?YlFVYmx6VUoxd0U1VVJBN01QN0Vwa1pFRFcrZ2NyVDNRRmNLdjJXUjNOTVcv?=
 =?utf-8?B?eXdlSWsxYVFEVHR0Y0ZkcXU1UnN4bVR5VlM2dHhEaFhkc0k4ZkN3NzB2dVFu?=
 =?utf-8?B?czQzd1orK1FwZEREUlpEY3pMZVRsb1p2ZmhVUnhVZ05TZmVxNDZJRVJ2cE1C?=
 =?utf-8?B?bFpaVmVBV3k0MHR4WWVXV2FQU3JDVDNUNm1sa1hBajhBOUZYS29kK2lhT2Ft?=
 =?utf-8?B?QTZ5cHVwN2txaCtyK0Y3UEpEekxBUVh0UnlGSmJQVHpKMFlsVDFQcGlaQ2ZJ?=
 =?utf-8?B?Rkl6NFdxOU9XSHNqQjZFTTFmNlEzUlM1Zy9mSzUzOG5lcnlsUjBEbTRYejZH?=
 =?utf-8?B?MzBRbmpsTjBkSVhHbnVjcnFjQ1JBUFpBWktYcWxqcEJXVHd5ajZ6bEplNS9m?=
 =?utf-8?B?N3FkT2ovVjJVRjVXTU1kNmRMYlZ3dGFQU2Z0K2JHS1pTY05DSmhibWZQcXVP?=
 =?utf-8?B?NkVoU1cydWpDc2VJUjZBTjZXa2J2QlBjOEdvaTM4NHFrWGlGbFIxVEJSWFNl?=
 =?utf-8?B?VXp6MDBwN2FsOUVuYnFPaFQ0RFpNV0ViV0hCS0psam1rd3BSVDZUYmttVEw0?=
 =?utf-8?B?emtNUXZ3MkZ5cElSbzhRV0J3Z0RIQ0JwQTlxZHUrdU5KQm5mTmVEd2grdDhw?=
 =?utf-8?B?dE9YTlYrL1pWVlIwMzYvV2ZFbUpEbFFWNXA5NUoyZkx1VHZCNHoycENTYlJ2?=
 =?utf-8?B?Z2w0Z0xsYlMrWHR1Wk96M3J3b2VZYlhFQWRPcHVqZmRNS0RYM004TnJadmpx?=
 =?utf-8?B?MVgwUnJuRDNrTXZxaHJ3NFFienFCSERlYmJ0SC9XK1hFQXhlMnFsdGRNRE5h?=
 =?utf-8?B?RWtva0hadFVMQXpGejZvUEc4QjN6eWkrRndtdUVxQWc1cGRxdWxVSFFUMnZP?=
 =?utf-8?B?RUVxNElwNlQvRHhtVy9NUnZyUXpJQ3RVejNBTHl2VXJ2UWhqMjN5dDh1WFpY?=
 =?utf-8?B?QkljdEFJdnk3bWx1VExicnZxc1Vnelo0MDhNaHRsTEtta1dFdWVJUWlEZjhI?=
 =?utf-8?B?RkZNbFBjc2xRR2pDWE0vQTZWeStyK0xhR3pSSWh4NS9mcU1lL0RjWlprM2Z0?=
 =?utf-8?B?SnNROFFrUWpsdlMxN3RIOXhpZTMvek9Wb0k5TmZuczZDbEFOaWliMDVVMU1m?=
 =?utf-8?B?S0N0dkN4S2lFZzNQYW5YbWczZ1kvVEdSNStpT2JKREgzMWRwTFYwaGp0V3hB?=
 =?utf-8?B?VjdlYzh5YUk1eC9aZVBueUZ3RHBEZWVGbkpnZTJlcWxIRXduQUhyczR3R2Nn?=
 =?utf-8?B?aTFZL2JpN0FhT0ZQNkM3akFKQWw3UFlYMllWZHI5cVpSU2Z3a1ZGK2t3UXho?=
 =?utf-8?B?clpBWUkvUFZ0dEo2WGVha3U5SElnT09hZi90bUFNcEhZaDBMYVI2cytaQUVm?=
 =?utf-8?B?WGpJZkZWTGFsTlBiNUMyM3hyQTFmTHFFOXZvZ3prWEZaZkFLY0VwSWdaaXpZ?=
 =?utf-8?B?MzhobE12dUpza0pIQ3IzZ2FIOUtYK0wyR25qNnVmNHFLQU5kVW5BRHJidnpP?=
 =?utf-8?B?U3BuU0JJVEk4RVlUTWxoYi9jK0MrdGlZTkNSR1doOGZsTXhETndiTys5akV6?=
 =?utf-8?B?dDNlV1dYMUdrRmVhc0Q3TXk5VEM4UCsrK1dkMHU1alNONGpyVEJ0R3BTbi8z?=
 =?utf-8?B?TUpPZTFmOUpzem9OY2prS3hTMHhqSVNBdlZxYlAySitPTDZFZzM5UGtwVnBu?=
 =?utf-8?Q?L2A9sPx3u1+FK?=
x-forefront-antispam-report: CIP:255.255.255.255; CTRY:; LANG:en; SCL:1; SRV:;
 IPV:NLI; SFV:NSPM; H:MW4PR19MB5630.namprd19.prod.outlook.com; PTR:; CAT:NONE;
 SFS:(13230040)(376014)(1800799024)(366016)(38070700018)(7053199007)(8096899003);
 DIR:OUT; SFP:1102; 
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0: =?utf-8?B?VjdXNFo0cFpvZmZ0MExmeCtkeE0yN0FuRVZiUExRL29pWHJVQ0l5MnU4MDRi?=
 =?utf-8?B?VnJhU1BoNytqTTBlcjhUdlFEVlhET3RFbkRyRmgzbTh5bXlCdERxVUF0Q3VM?=
 =?utf-8?B?T24vNTJYVnlYOUlKZnoyL3Q5VXFOSTI0TzA0N3RGQjgyVGw4clU3S3ZnRmJ2?=
 =?utf-8?B?bE9vMGhHNXZ0alFLbmV5RXZIU2tWV0JGVEJwR29GZGxaTDJuQ0lNaHcwTHpu?=
 =?utf-8?B?ay9veUN2WWJkRXM4b08xSGVkN1FOeVJ4QSt0S3lVVTJ1ODlzUFRZZ3M1WHZa?=
 =?utf-8?B?d0VnL1pLZmxRODJhN21DTTlNaVdPeE5JekNZSzRCVXdmTU1ObllUZzFMNXBY?=
 =?utf-8?B?dmJjcVJvZDlSZHMybWdaOXozNGhTNHdwdHNIK2hmQnJ0VXNyK00ydmJTRlE0?=
 =?utf-8?B?KzZiZ0pDU2ZvenlMeExOSFZiSnlFTlNYU2ZUR1ZzRzYxd0F2Y3dVNnpINW1j?=
 =?utf-8?B?alFKclV0Rlh0Ykg4bzVEWGFQOS9TaW1KS0V5TVVyZ1RER3pXUTd4RGtGS3ZY?=
 =?utf-8?B?MUpoUlJFL0M5b3hka2xCVFJmU1krUG80UmJTUGVrRENkYkozcGl2TVQ1cEE3?=
 =?utf-8?B?NDExUGtONmN1RXp3SE1SbXg4T3F1bW1tNUF6MmpDd1pKaHZHQmp2U2RBb09D?=
 =?utf-8?B?dWVmWS9uNTk3bThYMU00b2ROSitpVU1xNzRjRzErY0didzVaWjF6L3pxankw?=
 =?utf-8?B?NnpGck5IR2MrcXZrNmV4Ty9jQ0dtZkRiOWc4dE9lYzVZTWxtaWorUzhpTmtZ?=
 =?utf-8?B?SVVpeGtSanROWDFZSU9ueUJ3NlFNSHVETjZjOE56UGdCczUvRXo3KzhCdGxh?=
 =?utf-8?B?bGZmL3NwYjgzYkpodDd4OURHd29VMW5sZTRVZThTcnl3TkhJQ00yS0F2OHpT?=
 =?utf-8?B?NmlJMzhlTXJDaDBuRUg1Qm8yc1NUMUFHY09MOGp2dFJmYTJ1ald2QXQxdVRs?=
 =?utf-8?B?VWZQSkxGcFBheXJ2NjRpQ3ExUUtyUzVSVWdOQmFyV1N2N2FSQWVJK1VGOTAr?=
 =?utf-8?B?RzFwanhud0t1eVF6dmFxaFlRV2U1UXh1SDA5RWwzSlYzYnNjVjByRDROQ1VP?=
 =?utf-8?B?WUV3aENHRlJucmF5YllpVFpWV2I0bVdha3EvOW52czBYOWN3aTFMTWRUUkpn?=
 =?utf-8?B?SWRzRXAzRjgzenljUWsvTnVtamtsOTRWN0Q1cFRpMXl1cUZyMGFDSDNzejZl?=
 =?utf-8?B?QnB6OHF2ODVVd0R4dDBQaWlMbk1EM2piT0NubDQzNnRoUEFFNEJ4SVNRZkVk?=
 =?utf-8?B?ekdUeWw1ejhtRGlNS21Hb1RpbWxrNE1FZlFERjhHaHRSTDNoTEp1aXJnMmVT?=
 =?utf-8?B?cFl0UjRXczBjaE5TUUs1ZlFZUnBLcTA2V1l3NjlSQjl5UlhjQUtiVTFmV0xS?=
 =?utf-8?B?bEdKUko1cEs4WmhrdmR1eklkMGFYSWdneEcyMlNiZitmU1Q1VkFVbndBWGk3?=
 =?utf-8?B?VXFQUVdpL05VWVRvb2Z5cnJVdjVpQ0gzNk1GYkVrQ0cyY3BjaEhQNlhSWTh2?=
 =?utf-8?B?YlRDVnJSNUx3RWNMREZjc3hOTEJKeEdzUDJRUzB6Skt4bzV1N2FCOWxXT0Yr?=
 =?utf-8?B?bXhPcDFkUURhVnIrVVVycXNxZDdXaDYxWjMxTlVNRys3NEJaU0UrVTQzM1Bh?=
 =?utf-8?B?aUx1NGxvSHRRNTFVNXhxV2NPV0JjSHRIdEVqMEthUHVkcEhwcndjRjE3L1hj?=
 =?utf-8?B?akQ0a0d2OXpSRERtQkVmUHVCNHhza1hIR09tbHhWSHBJRlNIL1RQU0ZzYWxH?=
 =?utf-8?B?c3QwRjJsRXM3alBGTmNBVWZwSC9FSm5hclRUZW5WaUhXSmVRKzRJR0R1NXd1?=
 =?utf-8?B?bE9uRlhIdDErM3lRQVZweWRTV0lVVUpLcUhwV0MyOGthTlJKamF6TVpVYmNo?=
 =?utf-8?B?M3gxZ21Ga011aG52SW5QeXB5UnpGWFhrZURiL2x3Ly9rUWpCd21BQ3V1bHEw?=
 =?utf-8?B?bURic0dDRnUrSkJGS1N6MVk1b3FRNThXMStETm5nYWlPcmt2dE1QVUxySTFY?=
 =?utf-8?B?THJMSGo4TERYRExxWDU3aEpXRzNFQlY2VVVCUnlHT2NOWUo2SW5QdzZ1aUc2?=
 =?utf-8?B?aUthR2NOVjA2QTE4UzZEOExKeXFjS3RJZFlEV0ozbVhHSkxYZHFOUi9JWEww?=
 =?utf-8?Q?0EEY=3D?=
MIME-Version: 1.0
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-0: ZZ06zWJZVW2QwGdDY7r1fYuU9l35YS6MRZZt6pE6Wv739BVvL/ilrlXdd2W+OkIe/vGjNVEkZemoQl7jPTRjNXAGWHrLK6DLFz2gg56g34uR9UIKcjYUrF5Lh3zZVXgz/jX2o08DzjQI7DKtsWttyRYB0PYkaqqrNqX1Y6Ix4v7GOfXKVvTDo2H2BxiQkWY3C5ZfLyuO3mVxwlXM5R3bCdoaCrGsYP/8JAt/34MNMUUz1LB2yV7aLC1MjPmiqiXcmCxrQ3YSHGxlWJK28GXXjb47jDjaP22hdLkkc0NNsHUMqS4NGtR1xAbkZRNayYaW4n+/4Sjp/2RTFcpnudRwteLujTOpJ9ZaA8e/cwSaRq/31Awpn0PrUoxoIb3f5ZgfneI15pMv2mxsFjF/r0iwlhNGJHQMZUwN9SDZSJfGCauSIFOMjXw+oAbxv6IFq+ucevwlviL/U3+P4urRpwM5aqaLItnp81YoArHZXT0x3+gqVXk9yFTYWVL1CezcPPtOB5wCJOMetW7/gv5g++Z31WzbTBQfvCarmK4fcpvZ9uM3AnQ3oPxY69u2dHd8L3nyBH370rv3SoKznS0lynF8HSGbqehBlgprCdCmx6OL7eM42aA8EBXaFAzxZBVmkG9WMuVqY+Un37ZHsPwpsvSgSQ==
X-OriginatorOrg: ddn.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: MW4PR19MB5630.namprd19.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 28b6fe1f-60e9-4a60-db24-08dd5e0329e8
X-MS-Exchange-CrossTenant-originalarrivaltime: 08 Mar 2025 05:36:23.6996 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 753b6e26-6fd3-43e6-8248-3f1735d59bb4
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: zZigr5z3EqpW6/OZAtEdL+vX1pAQ7r2yEJMt0wXrimWUZR8Lg7qhAET5MfeIOh2G
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SJ0PR19MB4477
X-BESS-ID: 1741412187-110838-28170-35679-1
X-BESS-VER: 2019.1_20250304.2151
X-BESS-Apparent-Source-IP: 104.47.55.175
X-BESS-Parts: H4sIAAAAAAACAzXLOw7CQAxF0b24ThHbjD/ZCqKIHUdpEAVTIKHsnSlC83T1pH
 P/Qn06LNDHTvB6w4KsNuoYp8+eRVsYmewlc/JeDeWWyJbVHM7p74/+vDyT6+UxMCScN1
 4xpawlhWkioaKWrHA+foHG7LyBAAAA
X-BESS-Outbound-Spam-Score: 0.10
X-BESS-Outbound-Spam-Report: Code version 3.2,
 rules version 3.2.2.262998 [from 
 cloudscan14-11.us-east-2a.ess.aws.cudaops.com]
 Rule breakdown below
 pts rule name              description
 ---- ---------------------- --------------------------------
 0.00 HTML_MESSAGE           BODY: HTML included in message 
 0.10 BSF_SC0_SA085          META: Custom Rule SA085 
 0.00 BSF_BESS_OUTBOUND      META: BESS Outbound 
X-BESS-Outbound-Spam-Status: SCORE=0.10 using account:ESS124931 scores of
 KILL_LEVEL=7.0 tests=HTML_MESSAGE, BSF_SC0_SA085, BSF_BESS_OUTBOUND
X-BESS-BRTS-Status: 1
Subject: Re: [lustre-devel] prevent lustre from using specific ports for
 socket connections
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
Content-Type: multipart/mixed; boundary="===============2928871835570278282=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============2928871835570278282==
Content-Language: en-US
Content-Type: multipart/alternative;
	boundary="_000_773F80A993574297BC8BB61477B25360ddncom_"

--_000_773F80A993574297BC8BB61477B25360ddncom_
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64

SSBoYXZlbid0IGxvb2tlZCBhdCB0aGlzIGluIGEgd2hpbGUsIGJ1dCB0aGVyZSBpcyBhIExpbnV4
IHBhY2thZ2Ugc29tZXRoaW5nIGxpa2UgInBvcnRyZXNlcnZlIiB0aGF0IGNhbiBob2xkIHBvcnRz
IGZvciBvdGhlciBzZXJ2aWNlcyB1bnRpbCB0aGV5IGFyZSBzdGFydGVkLg0KDQpDaGVlcnMsIEFu
ZHJlYXMNCg0KT24gTWFyIDYsIDIwMjUsIGF0IDE1OjE2LCBEZWZhemlvLCBHaWFuLUNhcmxvIDxk
ZWZhemlvMUBsbG5sLmdvdj4gd3JvdGU6DQoNCu+7vw0KSGksDQoNCklzIGl0IHBvc3NpYmxlIHRv
IHByZXZlbnQgbHVzdHJlIGZyb20gdXNpbmcgc3BlY2lmaWMgcG9ydHMgd2hlbiBlc3RhYmxpc2hp
bmcgYSBzb2NrZXQgY29ubmVjdGlvbj8NCldlIGhhdmUgdGhlIHNpdHVhdGlvbiB3aGVyZSBsdXN0
cmUgbWF5IHVzZSBhIHBvcnQgKDEwMjIpIGFuZCB0aGVuIGEgc2VydmljZSB0aGF0IG5lZWRzIHRv
IHVzZSB0aGF0IHBvcnQgZmFpbHMgdG8gc3RhcnQuDQoNCk91ciBjdXJyZW50IHNvbHV0aW9uIGlz
IGEgbG9jYWwgcGF0Y2ggdG8gY2hlY2sgdGhlIHBvcnQgdmFsdWVzIGJlaW5nIGl0ZXJhdGVkIHRo
cm91Z2ggaW4gbG5ldC9sbmV0L2FjY2VwdG9yLmM6bG5ldF9jb25uZWN0KCkgYW5kIHRvIGp1c3Qg
c2tpcCBvdmVyIDEwMjIuDQoNCklzIHRoZXJlIGFscmVhZHkgYSB3YXkgdG8gYXZvaWQgY2VydGFp
biBwb3J0cyBmb3IgbHVzdHJlPyBFaXRoZXIgaW4gbHVzdHJlIG9yIHZpYSBzb21lIGtlcm5lbCBt
ZWNoYW5pc20gdGhhdCB3b3VsZCBhZmZlY3QgbHVzdHJlPw0KDQpXZSdyZSBjb25zaWRlcmluZyBt
YWtpbmcgYSBtb3JlIGdlbmVyYWwgcGF0Y2ggdGhhdCB3b3VsZCBhbGxvdyBzcGVjaWZ5aW5nIHBv
cnRzIHRvIGF2b2lkIGJ5IGFkZGluZyBhIG1vZHVsZSBwYXJhbWV0ZXIgdG8gbG5ldCBidXQgYXJl
bid0IHN1cmUgd2hhdCBhIGdvb2QgZGVzaWduIHdvdWxkIGJlLiBTbyBmYXIsIHRoZSBiYXNpYyBp
ZGVhIGlzIHRoYXQgdGhlIHVzZXIgc3VwcGxpZXMgYSBzdHJpbmcgb2YgbnVtYmVycy9yYW5nZXMg
c3VjaCBhcyAiNTEyLDUxMy01MTUsMTAyMiIgYW5kIHRoZW4gYSBsaXN0IG9yIGJpdG1hcCBvciBz
b21lIG90aGVyIGRhdGEgc3RydWN0dXJlIG9mIHBvcnRzIHRvIGF2b2lkIGlzIGNyZWF0ZWQgYW5k
IHRoZW4gbG5ldF9jb25uZWN0KCkgY2hlY2tzIHRoYXQgZGF0YSBzdHJ1Y3R1cmUgd2hlbiBzZWxl
Y3RpbmcgcG9ydHMuDQoNClRoYW5rcywNCkdpYW4tQ2FybG8NCl9fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fDQpsdXN0cmUtZGV2ZWwgbWFpbGluZyBsaXN0DQps
dXN0cmUtZGV2ZWxAbGlzdHMubHVzdHJlLm9yZw0KaHR0cDovL2xpc3RzLmx1c3RyZS5vcmcvbGlz
dGluZm8uY2dpL2x1c3RyZS1kZXZlbC1sdXN0cmUub3JnDQo=

--_000_773F80A993574297BC8BB61477B25360ddncom_
Content-Type: text/html; charset="utf-8"
Content-ID: <24BD33F935DB0B40B5ADB653CA9A07A8@teamddn.com>
Content-Transfer-Encoding: base64

PGh0bWw+DQo8aGVhZD4NCjxtZXRhIGh0dHAtZXF1aXY9IkNvbnRlbnQtVHlwZSIgY29udGVudD0i
dGV4dC9odG1sOyBjaGFyc2V0PXV0Zi04Ij4NCjwvaGVhZD4NCjxib2R5IGRpcj0iYXV0byI+DQpJ
IGhhdmVuJ3QgbG9va2VkIGF0IHRoaXMgaW4gYSB3aGlsZSwgYnV0IHRoZXJlIGlzIGEgTGludXgg
cGFja2FnZSBzb21ldGhpbmcgbGlrZSAmcXVvdDtwb3J0cmVzZXJ2ZSZxdW90OyB0aGF0IGNhbiBo
b2xkIHBvcnRzIGZvciBvdGhlciBzZXJ2aWNlcyB1bnRpbCB0aGV5IGFyZSBzdGFydGVkLiZuYnNw
Ow0KPGRpdj48YnIgaWQ9ImxpbmVCcmVha0F0QmVnaW5uaW5nT2ZTaWduYXR1cmUiPg0KPGRpdiBk
aXI9Imx0ciI+Q2hlZXJzLCBBbmRyZWFzPC9kaXY+DQo8ZGl2IGRpcj0ibHRyIj48YnI+DQo8Ymxv
Y2txdW90ZSB0eXBlPSJjaXRlIj5PbiBNYXIgNiwgMjAyNSwgYXQgMTU6MTYsIERlZmF6aW8sIEdp
YW4tQ2FybG8gJmx0O2RlZmF6aW8xQGxsbmwuZ292Jmd0OyB3cm90ZTo8YnI+DQo8YnI+DQo8L2Js
b2NrcXVvdGU+DQo8L2Rpdj4NCjxibG9ja3F1b3RlIHR5cGU9ImNpdGUiPg0KPGRpdiBkaXI9Imx0
ciI+77u/DQo8bWV0YSBuYW1lPSJHZW5lcmF0b3IiIGNvbnRlbnQ9Ik1pY3Jvc29mdCBXb3JkIDE1
IChmaWx0ZXJlZCBtZWRpdW0pIj4NCiA8c3R5bGU+QGZvbnQtZmFjZSB7IGZvbnQtZmFtaWx5OiAi
Q2FtYnJpYSBNYXRoIjsgfQ0KQGZvbnQtZmFjZSB7IGZvbnQtZmFtaWx5OiBBcHRvczsgfQ0KcC5N
c29Ob3JtYWwsIGxpLk1zb05vcm1hbCwgZGl2Lk1zb05vcm1hbCB7IG1hcmdpbjogMGluOyBmb250
LXNpemU6IDEycHQ7IGZvbnQtZmFtaWx5OiBBcHRvcywgc2Fucy1zZXJpZjsgfQ0Kc3Bhbi5FbWFp
bFN0eWxlMTcgeyBmb250LWZhbWlseTogQXB0b3MsIHNhbnMtc2VyaWY7IGNvbG9yOiB3aW5kb3d0
ZXh0OyB9DQouTXNvQ2hwRGVmYXVsdCB7IH0NCkBwYWdlIFdvcmRTZWN0aW9uMSB7IHNpemU6IDgu
NWluIDExaW47IG1hcmdpbjogMWluOyB9DQpkaXYuV29yZFNlY3Rpb24xIHsgcGFnZTogV29yZFNl
Y3Rpb24xOyB9PC9zdHlsZT4NCjxkaXYgY2xhc3M9IldvcmRTZWN0aW9uMSI+DQo8cCBjbGFzcz0i
TXNvTm9ybWFsIj48c3BhbiBzdHlsZT0iZm9udC1zaXplOjExLjBwdCI+SGksPG86cD48L286cD48
L3NwYW4+PC9wPg0KPHAgY2xhc3M9Ik1zb05vcm1hbCI+PHNwYW4gc3R5bGU9ImZvbnQtc2l6ZTox
MS4wcHQiPjxvOnA+Jm5ic3A7PC9vOnA+PC9zcGFuPjwvcD4NCjxwIGNsYXNzPSJNc29Ob3JtYWwi
PjxzcGFuIHN0eWxlPSJmb250LXNpemU6MTEuMHB0Ij5JcyBpdCBwb3NzaWJsZSB0byBwcmV2ZW50
IGx1c3RyZSBmcm9tIHVzaW5nIHNwZWNpZmljIHBvcnRzIHdoZW4gZXN0YWJsaXNoaW5nIGEgc29j
a2V0IGNvbm5lY3Rpb24/PG86cD48L286cD48L3NwYW4+PC9wPg0KPHAgY2xhc3M9Ik1zb05vcm1h
bCI+PHNwYW4gc3R5bGU9ImZvbnQtc2l6ZToxMS4wcHQiPldlIGhhdmUgdGhlIHNpdHVhdGlvbiB3
aGVyZSBsdXN0cmUgbWF5IHVzZSBhIHBvcnQgKDEwMjIpIGFuZCB0aGVuIGEgc2VydmljZSB0aGF0
IG5lZWRzIHRvIHVzZSB0aGF0IHBvcnQgZmFpbHMgdG8gc3RhcnQuPG86cD48L286cD48L3NwYW4+
PC9wPg0KPHAgY2xhc3M9Ik1zb05vcm1hbCI+PHNwYW4gc3R5bGU9ImZvbnQtc2l6ZToxMS4wcHQi
PjxvOnA+Jm5ic3A7PC9vOnA+PC9zcGFuPjwvcD4NCjxwIGNsYXNzPSJNc29Ob3JtYWwiPjxzcGFu
IHN0eWxlPSJmb250LXNpemU6MTEuMHB0Ij5PdXIgY3VycmVudCBzb2x1dGlvbiBpcyBhIGxvY2Fs
IHBhdGNoIHRvIGNoZWNrIHRoZSBwb3J0IHZhbHVlcyBiZWluZyBpdGVyYXRlZCB0aHJvdWdoIGlu
IGxuZXQvbG5ldC9hY2NlcHRvci5jOmxuZXRfY29ubmVjdCgpIGFuZCB0byBqdXN0IHNraXAgb3Zl
ciAxMDIyLjxvOnA+PC9vOnA+PC9zcGFuPjwvcD4NCjxwIGNsYXNzPSJNc29Ob3JtYWwiPjxzcGFu
IHN0eWxlPSJmb250LXNpemU6MTEuMHB0Ij48bzpwPiZuYnNwOzwvbzpwPjwvc3Bhbj48L3A+DQo8
cCBjbGFzcz0iTXNvTm9ybWFsIj48c3BhbiBzdHlsZT0iZm9udC1zaXplOjExLjBwdCI+SXMgdGhl
cmUgYWxyZWFkeSBhIHdheSB0byBhdm9pZCBjZXJ0YWluIHBvcnRzIGZvciBsdXN0cmU/IEVpdGhl
ciBpbiBsdXN0cmUgb3IgdmlhIHNvbWUga2VybmVsIG1lY2hhbmlzbSB0aGF0IHdvdWxkIGFmZmVj
dCBsdXN0cmU/PG86cD48L286cD48L3NwYW4+PC9wPg0KPHAgY2xhc3M9Ik1zb05vcm1hbCI+PHNw
YW4gc3R5bGU9ImZvbnQtc2l6ZToxMS4wcHQiPjxvOnA+Jm5ic3A7PC9vOnA+PC9zcGFuPjwvcD4N
CjxwIGNsYXNzPSJNc29Ob3JtYWwiPjxzcGFuIHN0eWxlPSJmb250LXNpemU6MTEuMHB0Ij5XZSdy
ZSBjb25zaWRlcmluZyBtYWtpbmcgYSBtb3JlIGdlbmVyYWwgcGF0Y2ggdGhhdCB3b3VsZCBhbGxv
dyBzcGVjaWZ5aW5nIHBvcnRzIHRvIGF2b2lkIGJ5IGFkZGluZyBhIG1vZHVsZSBwYXJhbWV0ZXIg
dG8gbG5ldCBidXQgYXJlbid0IHN1cmUgd2hhdCBhIGdvb2QgZGVzaWduIHdvdWxkIGJlLiBTbyBm
YXIsIHRoZSBiYXNpYyBpZGVhIGlzIHRoYXQgdGhlDQogdXNlciBzdXBwbGllcyBhIHN0cmluZyBv
ZiBudW1iZXJzL3JhbmdlcyBzdWNoIGFzICZxdW90OzUxMiw1MTMtNTE1LDEwMjImcXVvdDsgYW5k
IHRoZW4gYSBsaXN0IG9yIGJpdG1hcCBvciBzb21lIG90aGVyIGRhdGEgc3RydWN0dXJlIG9mIHBv
cnRzIHRvIGF2b2lkIGlzIGNyZWF0ZWQgYW5kIHRoZW4gbG5ldF9jb25uZWN0KCkgY2hlY2tzIHRo
YXQgZGF0YSBzdHJ1Y3R1cmUgd2hlbiBzZWxlY3RpbmcgcG9ydHMuPG86cD48L286cD48L3NwYW4+
PC9wPg0KPHAgY2xhc3M9Ik1zb05vcm1hbCI+PHNwYW4gc3R5bGU9ImZvbnQtc2l6ZToxMS4wcHQi
PjxvOnA+Jm5ic3A7PC9vOnA+PC9zcGFuPjwvcD4NCjxwIGNsYXNzPSJNc29Ob3JtYWwiPjxzcGFu
IHN0eWxlPSJmb250LXNpemU6MTEuMHB0Ij5UaGFua3MsPG86cD48L286cD48L3NwYW4+PC9wPg0K
PHAgY2xhc3M9Ik1zb05vcm1hbCI+PHNwYW4gc3R5bGU9ImZvbnQtc2l6ZToxMS4wcHQiPkdpYW4t
Q2FybG8gPG86cD48L286cD48L3NwYW4+PC9wPg0KPC9kaXY+DQo8c3Bhbj5fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXzwvc3Bhbj48YnI+DQo8c3Bhbj5sdXN0
cmUtZGV2ZWwgbWFpbGluZyBsaXN0PC9zcGFuPjxicj4NCjxzcGFuPmx1c3RyZS1kZXZlbEBsaXN0
cy5sdXN0cmUub3JnPC9zcGFuPjxicj4NCjxzcGFuPmh0dHA6Ly9saXN0cy5sdXN0cmUub3JnL2xp
c3RpbmZvLmNnaS9sdXN0cmUtZGV2ZWwtbHVzdHJlLm9yZzwvc3Bhbj48YnI+DQo8L2Rpdj4NCjwv
YmxvY2txdW90ZT4NCjwvZGl2Pg0KPC9ib2R5Pg0KPC9odG1sPg0K

--_000_773F80A993574297BC8BB61477B25360ddncom_--

--===============2928871835570278282==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============2928871835570278282==--
