Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 8FFBCCCFA03
	for <lustre-devel@archiver.kernel.org>; Tue,  4 Nov 2025 00:20:44 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4d0pv634pwz20js;
	Mon, 03 Nov 2025 16:17:54 -0800 (PST)
Received: from outbound-ip168a.ess.barracuda.com
 (outbound-ip168a.ess.barracuda.com [209.222.82.36])
 (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4d0psF1cDRz20fS
 for <lustre-devel@lists.lustre.org>; Mon, 03 Nov 2025 16:16:16 -0800 (PST)
Received: from SJ2PR03CU001.outbound.protection.outlook.com
 (mail-westusazon11022121.outbound.protection.outlook.com [52.101.43.121]) by
 mx-outbound41-234.us-east-2c.ess.aws.cudaops.com (version=TLSv1.2
 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
 Tue, 04 Nov 2025 00:15:36 +0000
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=NqjsQTZuPlJ37CGLie9Fqpyd6yKIZ/laB+3rjp/jnOFIySdbgx3pfpi3uuyz7GJJlBE6tInsEKHvfd8Lxprh3F+mD72wescXZkhEiRXBt6u4z5tqBhiz+UlLYAKSd/mS4kHqEM/GJvu6Ekv8N9bBLE9POp2AeBpVxYQJaWT7JxuXzuNLIl7q1z4FHuWTHXcky+VFKaC9E1F8UkBqCpXN0ghy4CyH9rimuPHYxykd96kE9EERYK+mfHfr0VfMyby4x1CXL//ylokt1gMyX7qIjzSKzrjpiW+PQL089q4/YFs7ztIVAt5bL2ocuJVN3TdJ+3q/5cnZYpwPluwTw8w/SQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com; 
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=re8tJ94v9p4id45oNLQ78QhTwz7OMRo7MmtdDooaM6s=;
 b=YFWlTyA3YSK5I0buifz9gQKgV/j/7ibWmK1ahzL2seZphnLmYaAR2DXNSb572TVRTgAG7G4DofM2c46f53PKy2M3CT3ea8flx10qXe2VbngCuYTTF8kYdOa1TQ0q5DKdX3z9W3gDlpxyYXYrxKYd4olGBiztc2pp5CeYancyMhsgGJzpyCHOb5dyLGLHOdUeQJBjSkw+/SZbHC4Zt2VoUGs5alua1nGTCLwyEguZbdbglnRaFV1gFe64g1HG9GLvgbbmGn1TCHkVLYao/IA4gZT2Dy2kMv7pfh9T8mQzDBrZNiVTZ/f8cE44Pe84SX84+1+YLXqIIx+0FJeGf/eBlw==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=whamcloud.com; dmarc=pass action=none
 header.from=whamcloud.com; dkim=pass header.d=whamcloud.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=whamcloud.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=re8tJ94v9p4id45oNLQ78QhTwz7OMRo7MmtdDooaM6s=;
 b=bLH2roAn3fjaD9ZGgoYbZBAASeNOZgx/a8x+wWKgyCPf1IU66u3/ccGZuNWyG9YMlXc4GkJK1lF8JYxX70s4qg6gDFWDRjtTW+yBHqET6XRNimRDHC7gLhUf5PwFfPRy43NSUWVlR/aj6LEJSxfKoAAFFmT7LQA/b0Ig3/JnGRE=
Received: from DM3PPF12B913643.namprd19.prod.outlook.com
 (2603:10b6:f:fc00::70b) by CH3PR19MB8189.namprd19.prod.outlook.com
 (2603:10b6:610:1a6::11) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.9275.16; Tue, 4 Nov
 2025 00:15:33 +0000
Received: from DM3PPF12B913643.namprd19.prod.outlook.com
 ([fe80::1dae:cea7:3265:124e]) by DM3PPF12B913643.namprd19.prod.outlook.com
 ([fe80::1dae:cea7:3265:124e%7]) with mapi id 15.20.9275.015; Tue, 4 Nov 2025
 00:15:32 +0000
To: "jinshan.xiong@gmail.com" <jinshan.xiong@gmail.com>
Thread-Topic: [lustre-devel] RFC: Spill device for Lustre OSD
Thread-Index: AQHcTQ1Fb2jVZEEEh0eTrPomJf0YLbThlTCAgAAN0oCAAAMmgA==
Date: Tue, 4 Nov 2025 00:15:32 +0000
Message-ID: <c6c016567a02f857303eedb9a4af6b5831c2c818.camel@whamcloud.com>
References: <e2c69a503e80f3ba59d69f093bc8df519cdd7f66.camel@whamcloud.com>
 <BFDDAAED-BA9A-44DB-BCD0-B3B84E652FE7@gmail.com>
In-Reply-To: <BFDDAAED-BA9A-44DB-BCD0-B3B84E652FE7@gmail.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=whamcloud.com;
x-ms-publictraffictype: Email
x-ms-traffictypediagnostic: DM3PPF12B913643:EE_|CH3PR19MB8189:EE_
x-ms-office365-filtering-correlation-id: cc473d31-d0fa-43c2-6bbf-08de1b3744e2
x-ms-exchange-senderadcheck: 1
x-ms-exchange-antispam-relay: 0
x-microsoft-antispam: BCL:0; ARA:13230040|1800799024|366016|376014|38070700021;
x-microsoft-antispam-message-info: =?utf-8?B?NjlNeXBGNWp3SURFcGdBRlBZUDJoVDdySHVuVjFucjAxbzUzc0RUNHdSSXRY?=
 =?utf-8?B?SGliRW9EWkNwWnFPWlpQZmJpQ1I1THJNVTdoc010cWZmN1BhNTNNVlFqcGx0?=
 =?utf-8?B?OFhpbi93Q1BTNzFPRzJ3Mjc1STZqSE1rdzdDU0p5OHdEdXE0QjA5N3VRTFd2?=
 =?utf-8?B?MnAwSEZJL3c3SVVuMHRMRlUrcWpEVnllN3lZQ0lkbnlUd21BZVBVeHFVNndl?=
 =?utf-8?B?Q1ZKRmJYbnFIbW90bGhzWWNNL0NSNnF2R2hIQXRJcUFkOUFGd2Vta2lpT1Bh?=
 =?utf-8?B?M2ZBcjhoVDZOVVoxWDFndVh3b2piaXM1RCt1M3dKc3ZJQkpnb1FTUmJmMHdT?=
 =?utf-8?B?d084MmZmVVNyc0hwV3hlNUgyVW42N3c4N1VjUjVEeGhaMUNqVWl4c0NWaUNs?=
 =?utf-8?B?S3hEb3VMdFkyRG1qeG9VSGMwWEZtNmU4d3ZFaHY5aXYrMUlvNnZLNkx2UEt0?=
 =?utf-8?B?S2ZibW95cm5aQmdXaEJmdHd0SHNkQjUvMmJ2blRRVHRBT0pubjJUMXhhZ0Vr?=
 =?utf-8?B?RzdFRUNyTEM2UXhnRE5JMVNYT0tWSno2QWNkREdNV2tXanpCMnZRR2lXakxq?=
 =?utf-8?B?N0hZNmprNFh2NUtXQXZTd2NIT3RwRTJZTDFncTh0azNhNVVKZXdLNXBOOXhD?=
 =?utf-8?B?SWl5WXNudlN0K0Q4eDNJT0Zpc2Q2WjMvTGtSSWlya0NnS3c5UEV2aG5NZGwz?=
 =?utf-8?B?cHlSM1pKU2NTNUZMYmRMK0lueDl0WnJNRXY4d2krd2xEMDNxeDFPdHZYUkVN?=
 =?utf-8?B?Ym1nSnBMUVhheDJ6YzZ2VG10Z002Z24zYkJxZUE5NUYxWXlqK2RMb0FzdnJB?=
 =?utf-8?B?WkxIV2U0L1F6RDZLaG90bVQzdlBwTDY3NTZQTjE2VmhOYTdyeDVJdTFLTWdw?=
 =?utf-8?B?b1MydXhENllLSGhYa0RENlZGVlBiZmp6V1Rqb0VmL2xIV3Rmd1E5eFNBVG4r?=
 =?utf-8?B?QkdiOHIxdStsRFNzVnhPWS9IRGFmMGNLR1ZEREFUd09oZjhza0daT2lFYlNv?=
 =?utf-8?B?aGJDLzJBMG5halJaKzdmMDVXemdyQ0I3dXc0UDU5Z280NXY4Z2J4SWwxY0t0?=
 =?utf-8?B?VjJuVktFSGhCWDRsaDd3MGx0OG5hcVJrTEJQSGZxTHN6aitGOTlIZFJyWG5y?=
 =?utf-8?B?dGJUbm11c2YyUk8vOE15NVFvUnJ1OUIyR21sL0FEenJmdUEydUxkOXBzYzYw?=
 =?utf-8?B?M1RyOUxPK085RzZST0JDbWRGeXRvK3VzZTVTTERkQ0dPMWVObXI3VmV0Tk1a?=
 =?utf-8?B?eDU5WG9FNUM1NzZMRDFqR3dyQzdEYmJORUJNNHVNbTFNQ2FhcVUxaVBiT3dP?=
 =?utf-8?B?YmoxcE9PUmQ3L24xOWIrSWJ6elpLNnZPaUtrdDVFUzNlREw3ckdjbXhRRmhY?=
 =?utf-8?B?R0ZhVjFrNmxLM3VYc2plOW5DblNTQ3ZFL293WGljOVpQNy9HMVdyc3lmZlgz?=
 =?utf-8?B?YTI5NnpDdzEybjRKajBPTVJIYmRUVzhtZXlwa3NzTjFJS245U2VzekZFN2ht?=
 =?utf-8?B?L2Q5cW1Ud21VKzhZQkdiTWVKcC83NGdlTWFiYUcyQldNemtMbHREMWQwNzBV?=
 =?utf-8?B?OTBKbTNLeTNaMTI3ZVdEcnd3SjNyMHpqcmt1UFRONmd0dWNNSmkzSDcxVEh3?=
 =?utf-8?B?SXpLMkxjZWQzNzRUaXdxRXJhTlhPQjZIK1VRL2NHMmNndVBnTWo2SEhxckha?=
 =?utf-8?B?azh1eEI1TExnL2R2d2JhbTJxejBrT0V4NUhncFQ0eUlCcndGMWR0amU3VUQ4?=
 =?utf-8?B?UWM0S2VGWDJKbkNobHlUL1VlM0JXZjhOOWx3RXowL040d0Z1Q1pHdGgyQjlU?=
 =?utf-8?B?MnRSOGVYTmxBNHlwRlROd0hCUDdJc1dxbWFsdmN2TCtzRjR6dFZpUk1HVXIz?=
 =?utf-8?B?YitnZFRyZ0VXZmZIQ2ZsVzVGdWFNVzFleW1Va0xiODc0M2JhMW1hc1NQRHlK?=
 =?utf-8?B?VW45SktLdWlYeUxrR3dDck9ZY1FiTk41YURxZ3ZoZHdkS0I0RzZEalN1RXpG?=
 =?utf-8?B?TnZqS2VJenMvR01kejN1bDZTRTBTRzhvL2dzdlp4K09TMG9GRGVxRSt4Zk9R?=
 =?utf-8?Q?WJl1PW?=
x-forefront-antispam-report: CIP:255.255.255.255; CTRY:; LANG:en; SCL:1; SRV:;
 IPV:NLI; SFV:NSPM; H:DM3PPF12B913643.namprd19.prod.outlook.com; PTR:; CAT:NONE;
 SFS:(13230040)(1800799024)(366016)(376014)(38070700021); DIR:OUT; SFP:1102; 
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0: =?utf-8?B?VE5tMWxYREZYRngwc0R2THNBY2ZONEVsZDR1NlE1UlM2aUh0MUVxWWhvYUxo?=
 =?utf-8?B?L0NES3NHdzdaeEVGdjBaOEFLQjJUeHRtVnBOSzU5V1RibXdzQzAydjNWa203?=
 =?utf-8?B?Tm5MZzFEc0hPOXNDQmFHVHcydlZ3bElCc0RjWVpvK25Ob3lTUXRNQ01aOHJU?=
 =?utf-8?B?Q3lTVCtWdmdKSnI5b1hmcnd5Zjd2MVJUZ0ZRbitIVk5LbnlPWEV6RWY4Q2Zq?=
 =?utf-8?B?LzBkcW9PR21ZZUxHL0F0MjJ0TWZWdStVZkR4cjdOMUFIOURGbmxoRmh5cHQ3?=
 =?utf-8?B?N0FIRmNsSlcxVzdyWC9zNUcwMHhVZXZnUUhKc1htSzNlUkNPK2RET2JNVE0r?=
 =?utf-8?B?UEg4VjhlT3o1YVNpajBGRTJONUZqSXdsTjN1bkZkbGJTYUh2TnlrVFZrdVlM?=
 =?utf-8?B?NzRpWjc5Qk1kOEE2QnVramxWaDV0SEg2VHZkRmpLMFhQLzlOWmhiQjBxUVhi?=
 =?utf-8?B?UXlBMGRHbytyeHprc3prbkgycnB4SDZGR2o3eExGbkFTbWZZTlFCNGlsRmhJ?=
 =?utf-8?B?UklHK0psbEM1RURWT25oenA3bVh1SXZrd29VYnNORFRDcTNrTmhrNFJTb1hQ?=
 =?utf-8?B?UjkremxQb1VnTHJnTDJyT1pCRUV3VUt5U21VZG93czBCbHZuc3l6R0hLblkz?=
 =?utf-8?B?NkpTVm80UllNQkxuS0RzME56WFhURk1UQTY5NmovMmxSRDhhUGtBcGVqRkJR?=
 =?utf-8?B?cHU5cDJPZmJ4QjRzQW1rMUV5MUdLaW16SlZ2d29FQXpaUlk5YWhlTFgyTlgr?=
 =?utf-8?B?akJYdWJURVVpcG5KcngzQnZTK2VFOVBTaFJwVlVBUmU2dDVQMytjNkUxazVq?=
 =?utf-8?B?UXZIMWI0bEduSjdUbGhsbFpCYVpyUXlLYkxGYkxyTE9uS0hPVzFnKzBNZXd6?=
 =?utf-8?B?K2U2LzJ5ZzRyTUtValZqaWpSUTE3K3FQTWU2Vkd3c1dTeDU1VktWUmQ4T0NB?=
 =?utf-8?B?ZVpiQVdrTThTZERVMGphM2hSeXFZZm9zOU1DaXhKMy9mVVJPd21iV2hZTGdu?=
 =?utf-8?B?SkdEQWwydnY5TXlZNi9uOE5GOVZodllKZkpEMWcwVkVNbGY4dTFRbFpqKzFw?=
 =?utf-8?B?d3JxTjVwY1lML1pkY21SeXk5K2dFamc3YnVER25rS2IxTm1BR3VMbXl3VVdH?=
 =?utf-8?B?cEFBVTI5K1BxYUlKL1A5VlhaMDBVdWJmSHlxSVRzWmlNRS9NaEhkdlpvQTdH?=
 =?utf-8?B?ZXNDOUZmekZIWXJLd3lhWFhtTHBRMTlHdjF2TGdzNHBXdFREdjZ3WUVnVUJ4?=
 =?utf-8?B?VVAwOURFOGdXZWVobU05TkJhS2lhbWxsMlVLTVVHZzVyV1NaQjdLcDRrbDNO?=
 =?utf-8?B?SE4xUEFrVDlpY1pHbWNYUCtVSEFkOEIzSWFoQUVoVWJvQ1FWdEtrVDI4akFI?=
 =?utf-8?B?NEZRVHFkM2Q1Y3d3ejJVN2ZKa29PbStGcXF4RXpDUnBVVHh2dzE2NGNNdllP?=
 =?utf-8?B?M1hNVUhLRXZhcUd5MlR4R2RGTmJPVU9TcTZmbHpZNjYzU3BZY2lEV2E0QnU1?=
 =?utf-8?B?M05tYzVWdiszOW90RTZWYy8vaVh1blpZcEZ4NjFtR3VCWTMrMDN0QzM3eVB5?=
 =?utf-8?B?ai9NTzRFQjhqd1UzMnJXREpRRWhDRXpJM3JTWTYzbnBGQjRqTHl2UDFLV3R0?=
 =?utf-8?B?Z3N6YnNFUzhxQ2RBOTdmRUVZNmxhWlc4ZjBoeFAxYkJTajREcW9rVklZUlJw?=
 =?utf-8?B?TUhUYlV1MENKWXdoMU1UNFFQQVRsNG0zZzZQcHpZSWgvelE3RTFFdEhrNjN3?=
 =?utf-8?B?ZjVoQ3d1aXh3RlVsZ2ZGbW4wd1lJSC82bnN5M3J6Y2x1aVB0N3R2TWZRWSs1?=
 =?utf-8?B?dEIrdVNNcWxoaURZSmNGZk1uL0QrNzZqZ3k1ZlNGYlpaYS9ZMDZtR241VHdp?=
 =?utf-8?B?cG9yaTRDU1d0b2pHcXd3K2N1VlBZcTg5NW0xM3E5QnBSV2hiUUlJVkoveUtL?=
 =?utf-8?B?clJ0RXJRVVRNU0J1dW1KVENJM0hyRUsvMTRjSndxQ3ZGblJ6UWRCL2xNZDE1?=
 =?utf-8?B?Wk9tZHNTbWtXTzdaaDZlVWc2WExlWktma05HaThQQ3QwOW1uTHViZTh4Unpz?=
 =?utf-8?B?WG1JaUV1NzhpMDBGZWc4U1EyeDNYTHVyQjhxUTUwSzZPTkMzZzExQ1RGYXlS?=
 =?utf-8?Q?c7WaKMuDz6Y9wX88G9z+1yuKJ?=
Content-ID: <D93FAD3571BAE44E8F95F699C34DF548@namprd19.prod.outlook.com>
MIME-Version: 1.0
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-0: sVsbdmzGUkrS54w3A9IG/IqPOd0KnT4DheuKzb50I3DbN82wzTw7HdGy3KbzGr4C8rP6CF3qf6tQCsIJfWFg4EhtqUFBTbgeLLoRmwqbNlpAheN5/HoBUBCL7BdgjybYifzHcf9ZGEHkUuAy0fVXtuV3u4R9qwzkKzIUbpGXc1AdBi+Unh1DG8AZLDgl5y7addHpSsekB0GqieU3+T2QJPkYXrn6A15mxb0c4VAAywgKHWWpTLK5YyaXuw/CbX5JAqVLE6kWH3lgCaMaSiW2EDS4lNFeofXsq5D+YTX9YCvYy7DRxQxdGmdDwb2cqYbr2PkWFUX8fUsze3/TxHquZ/VdYsnUkvGzYpf80enRZ/0bGU/XBmOvQLI/Fur1BOwi9rYVh2UDKMWwrLK3djaCuFoAA0132tgTOT5cdyDSF6aU3XyGjar6DbJDVOCqQmVPbkQkl10nfP/stHQ3zXG8etCswN6rEJ5doJv+1Vs4o2KH35RLMlFPzu39yIExxmNqUpYyT946EUg8RLXfWPCsIESPlhbfPOI6cA2d96l7JPiW+48Ps1ZLnp7xsLvQycaI2SBjx/iD3Vqf6Nvmzsb4lZD7Jf7gPxp20otjv8djKvQJ0GkTQqcepk5uT4TSIUVG5olPvmVwtO6Y+ywEADqYqQKzdNp+M/aYQFr9x4eIQGM=
X-OriginatorOrg: whamcloud.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: DM3PPF12B913643.namprd19.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: cc473d31-d0fa-43c2-6bbf-08de1b3744e2
X-MS-Exchange-CrossTenant-originalarrivaltime: 04 Nov 2025 00:15:32.5719 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 753b6e26-6fd3-43e6-8248-3f1735d59bb4
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: GtCna8xRa2i3uxL2/O0+kSbVGppHSQ7ijWsaTtIsBZfzDR9R9Ev7nYceJJMl1uzq
X-MS-Exchange-Transport-CrossTenantHeadersStamped: CH3PR19MB8189
X-BESS-ID: 1762215335-110730-12397-45021-1
X-BESS-VER: 2019.1_20251103.1605
X-BESS-Apparent-Source-IP: 52.101.43.121
X-BESS-Parts: H4sIAAAAAAACA4uuVkqtKFGyUioBkjpK+cVKVsZGhhZAVgZQMCUlLc3I2MwQJG
 RgbGlumWSUZGxkamGQZGhuZJSUplQbCwAu9AwNQQAAAA==
X-BESS-Outbound-Spam-Score: 0.00
X-BESS-Outbound-Spam-Report: Code version 3.2,
 rules version 3.2.2.268690 [from 
 cloudscan14-185.us-east-2a.ess.aws.cudaops.com]
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
Cc: "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

T24gTW9uLCAyMDI1LTExLTAzIGF0IDE2OjA0IC0wODAwLCBKaW5zaGFuIFhpb25nIHdyb3RlOg0K
PiANCj4gDQo+ID4gT24gTm92IDMsIDIwMjUsIGF0IDE1OjE0LCBPbGVnIERyb2tpbiA8Z3JlZW5A
d2hhbWNsb3VkLmNvbT4gd3JvdGU6DQo+ID4gDQo+ID4g77u/T24gTW9uLCAyMDI1LTExLTAzIGF0
IDIxOjU5ICswMDAwLCBEYXksIFRpbW90aHkgdmlhIGx1c3RyZS1kZXZlbA0KPiA+IHdyb3RlOg0K
PiA+ID4gDQo+ID4gPiANCj4gPiA+IFRoaXMgYmVncyB0aGUgcXVlc3Rpb246IGlmIHdlJ3JlIGFs
cmVhZHkgZG9pbmcgdGhpcyB3b3JrIHRvDQo+ID4gPiBzdXBwb3J0DQo+ID4gPiB3cml0aW5nIEx1
c3RyZSBvYmplY3RzIHRvIGFueSBhcmJpdHJhcnkgZmlsZXN5c3RlbSB2aWEgVkZTIGFuZA0KPiA+
ID4gd2UncmUNCj4gPiA+IG9ubHkNCj4gPiA+IGludGVuZGluZyB0byBzdXBwb3J0IE9TVHMgd2l0
aCB0aGlzIHByb3Bvc2FsLCB3aHkgbm90IGltcGxlbWVudA0KPiA+ID4gYW4gT1NULW9ubHkgVkZT
IE9TRCBhbmQgaGFuZGxlIHRpZXJpbmcgaW4gdGhlIGZpbGVzeXN0ZW0gbGF5ZXI/DQo+ID4gDQo+
ID4gVGhlIHByb2JsZW0gd2l0aCBwdXJlIFZGUyBpcyBpdCBkb2VzIG5vdCBhY3R1YWxseSBwcm92
aWRlIHVzIHdoYXQNCj4gPiB3ZQ0KPiA+IHdhbnQuDQo+ID4gU28gT1NEIHRhbGtzIHRvIHRoZSB1
bmRlcmx5aW5nIEZTIHZpYSBWRlMgKyBzb21lIG1vcmUgc3R1ZmYgKHdlIGRvDQo+ID4gaGF2ZQ0K
PiA+IHRoZSBoaWRkZW4gbW91bnQgZm9yIGxkaXNrZnMgYWZ0ZXIgYWxsKS4NCj4gPiBUaGUgIm1v
cmUgc3R1ZmYiIGlzIHRoaW5ncyBsaWtlIGV4cGFuZGVkIHRyYW5zYWN0aW9uIGJvdW5kYXJpZXMN
Cj4gPiBiZXlvbmQNCj4gPiB3aGF0IHBvc2l4IHJlcXVpcmVzIHNvIHdlIGNhbiB1cGRhdGUgbW9y
ZSB0aGFuIG9uZSB0aGluZy4NCj4gPiBJZiBMaW51eCBWRlMgcHJvdmlkZWQgYWxsIHRoZXNlIGFi
aWxpdGllcyB3ZSB3b3VsZCBub3QgbmVlZCB0bw0KPiA+IHJlYWxseQ0KPiA+IGtub3cgbXVjaCBh
Ym91dCB0aGUgdW5kZXJseWluZyBkaXNrIGZzIEkgc3VzcGVjdC4NCj4gPiANCj4gPiBCdXQgY3Vy
cmVudGx5IGl0J3MganVzdCBhIHdheSB0byBhZGQgT1NUcywgbm90IG1vdmUgb2JqZWN0cw0KPiA+
IGxhdGVyYWxseQ0KPiA+IGZyb20gb25lIE9TVCB0byBhbm90aGVyIGFuZCBoZW5jZSB0aGlzIHBy
b3Bvc2FsIEkgaW1hZ2luZSAtIHdoZXJlDQo+ID4gT1NUcw0KPiA+IHdvdWxkIGdyb3cgIndhcnRz
IiBmb3IgbGVzcyB3YW50ZWQgZGF0YS4NCj4gPiANCj4gPiBJIGFtIG5vdCBzdXJlIGl0J3MgYSBt
dWNoIGJldHRlciBpZGVhIHRoYW4gdGhlIGFscmVhZHkgZXhpc3RpbmcgSFNNDQo+ID4gY2FwYWJp
bGl0aWVzIHdlIGhhdmUgdGhhdCB3b3VsZCBhbGxvdyB5b3UgdG8gaGF2ZSAib2ZmbGluZSIgb2Jq
ZWN0cw0KPiA+IHRoYXQgd291bGQgYmUgcHVsbGVkIGJhY2sgaW4gd2hlbiB1c2VkLCBidXQgYXJl
IG90aGVyd2lzZSBqdXN0DQo+ID4gdmlzaWJsZQ0KPiA+IGluIHRoZSBtZXRhZGF0YSBvbmx5Lg0K
PiA+IFRoZSB1bmRlcmx5aW5nIGNhcGFiaWxpdGllcyBhcmUgcHJldHR5IHJpY2ggZXNwLiBpZiB3
ZSBhbHNvIHRha2UNCj4gPiBpbnRvDQo+ID4gYWNjb3VudCB0aGUgZXZlbnR1YWwgV0JDIHN0dWZm
Lg0KPiANCj4gVGhlIG1ham9yIHByb2JsZW0gb2YgY3VycmVudCBIU00gaXMgdGhhdCBpdCBoYXMg
dG8gaGF2ZSBkZWRpY2F0ZWQNCj4gY2xpZW50cyB0byBtb3ZlIGRhdGEuIEFsc28sIHNjYW5uaW5n
IHRoZSBlbnRpcmUgTHVzdHJlIGZpbGUgc3lzdGVtDQoNClRoaXMgKGRlZGljYXRlZCBjbGllbnQp
IGlzIGFuIGltcGxlbWVudGF0aW9uIGRldGFpbC4gSXQgY291bGQgYmUNCmltcHJvdmVkIGluIG1h
bnkgd2F5cyBhbmQgdGhlIGVmZm9ydCBzcGVudCBvbiB0aGlzIHdvdWxkIGJyaW5nIGdyZWF0DQpi
ZW5lZml0IHRvIGV2ZXJ5b25lPw0KDQo+IHRha2VzIHZlcnkgbG9uZyB0aW1lIHNvIGl0IHJlc29y
dHMgdG8gZGF0YWJhc2VzIGluIG9yZGVyIHRvIG1ha2UNCj4gY29ycmVjdCBkZWNpc2lvbnMgYWJv
dXQgd2hpY2ggZmlsZSBzaG91bGQgYmUgcmVsZWFzZWQuIEJ5IHRoZSB0aW1lLA0KPiB0aGUgdHdv
IHN5c3RlbSB3aWxsIGJlIG91dCBvZiBzeW5jLiBUaGF0IG1ha2VzIGl0IHByYWN0aWNhbGx5DQo+
IHVudXNhYmxlLg0KDQpUaGlzIGFnYWluIGlzIGFuIGltcGxlbWVudGF0aW9uIGRldGFpbCwgbm90
IGV2ZW4gaGFyZGNvZGVkIGFueXdoZXJlLg0KSG93IGRvIHlvdSBwbGFuIGZvciB0aGUgT1NUIHRv
IHRvIGtub3cgd2hhdCBzdHVmZiBpcyBub3QgdXNlZCB3aXRob3V0DQpyZXNvcnRpbmcgdG8gc29t
ZSBkYXRhYmFzZSBvciBzY2FuPyBOb3cgdGFrZSB0aGlzIG1ldGhvZCBhbmQgbWFrZSBpdA0KcmVw
b3J0ICJ1cHN0cmVhbSIgd2hlcmUgY3VycmVudGx5IEhTTSBpbXBsZW1lbnRhdGlvbnMgcmVzb3J0
IHRvDQpkYXRhYmFzZXMgb3Igc2NhbnMuDQoNClJlcmVhZGluZyB5b3VyIHByb3Bvc2FsLCBJIHNl
ZSB0aGF0IHRoaXMgcGFydGljdWxhciBkZXRhaWwgaXMgbm90DQpjb3ZlcmVkIGFuZCBpdCdzIGp1
c3QgYXNzdW1lZCB0aGF0ICJpbmZyZXF1ZW50bHkgYWNjZXNzZWQgZGF0YSIgd291bGQNCmJlIHNv
bWVob3cga25vd24uDQoNCj4gDQo+ID4gDQo+ID4gSWYgdGhlIGFyZ3VtZW50IGlzICJidXQgT1NU
cyBrbm93IGJlc3Qgd2hhdCBzdHVmZiBpcyB1c2VkIiAod2hpY2ggSQ0KPiA+IGFtDQo+ID4gbm90
IHN1cmUgSSBidXksIGFmdGVyIGFsbCBiZWZvcmUgeW91IGNvdWxkIHVzZSBzb21ldGhpbmcgb2Zm
IE9TVHMNCj4gPiB5b3UNCj4gPiBuZWVkIHRvIG9wZW4gYSBmaWxlIEkgd291bGQgaG9wZSkgZXZl
biB0aGVuIE9TVHMgY291bGQganVzdCBzaWduYWwNCj4gPiBhDQo+ID4gbGlzdCBvZiAiaW5hY3Rp
dmUgb2JqZWN0cyIgdGhhdCB0aGVuIGEgaGlnaGVyIGxldmVsIHN5c3RlbSB3b3VsZA0KPiA+IHRh
a2UNCj4gPiBjYXJlIG9mIGJ5IHJlbG9jYXRpaW5nIHNvbWV3aGVyZSBtb3JlIHNlbnNpY2FsIGFu
ZCBjaGFuZ2luZyB0aGUNCj4gPiBsYXlvdXQNCj4gPiB0byBpbmRpY2F0ZSB0aG9zZSBvYmplY3Rz
IG5vdyBsaXZlIGVsc2V3aGVyZS4NCj4gPiANCj4gPiBUaGUgcGx1cyBoZXJlIGlzIHlvdSBkb24n
dCBuZWVkIHRvIGF0dGFjaCB0aGlzICJXYXJ0IiB0byBldmVyeSBPU1QNCj4gPiBhbmQNCj4gPiBj
b25maWd1cmUgaXQgZXZlcnl3aGVyZSBhbmQgc3VjaCwgYnV0IHJhdGhlciBoYXZlIGEgY2VudHJh
bA0KPiA+IGxvY2F0aW9uDQo+ID4gdGhhdCBpcyBjZW50cmFsbHkgbWFuYWdlZC4NCj4gPiANCg0K
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KbHVzdHJlLWRl
dmVsIG1haWxpbmcgbGlzdApsdXN0cmUtZGV2ZWxAbGlzdHMubHVzdHJlLm9yZwpodHRwOi8vbGlz
dHMubHVzdHJlLm9yZy9saXN0aW5mby5jZ2kvbHVzdHJlLWRldmVsLWx1c3RyZS5vcmcK
