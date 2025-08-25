Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 62E52CA0EFA
	for <lustre-devel@archiver.kernel.org>; Mon, 25 Aug 2025 17:04:39 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4c9cRn4y8jz235P;
	Mon, 25 Aug 2025 09:57:57 -0700 (PDT)
Received: from outbound-ip168a.ess.barracuda.com
 (outbound-ip168a.ess.barracuda.com [209.222.82.36])
 (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4c9cKL07YTz23NT
 for <lustre-devel@lists.lustre.org>; Mon, 25 Aug 2025 09:52:21 -0700 (PDT)
Received: from NAM10-MW2-obe.outbound.protection.outlook.com
 (mail-mw2nam10on2090.outbound.protection.outlook.com [40.107.94.90]) by
 mx-outbound45-176.us-east-2c.ess.aws.cudaops.com (version=TLSv1.2
 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
 Mon, 25 Aug 2025 16:51:55 +0000
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=TKHltK/V1gPEt1N9pYc8uDiQ6sB/OdqE9X2irjN8HnnMHbqlVVIAB/1irhRQgKLlERElCm3Cuj90Bdk0LqDBSyMC9fnKYMNkUrg+pQyUBt8mQIsFYnYOSZpSch+3FlytJsVw4XTyZgoogl2SpdxAEbfPCdysmXYsr7L2IH7Kva+NS/ucAr10/SXChPCsCY02ixlvDZuDVoZxTmD5Yu7sV1YHECLv5e8vV3dY0nNJb/aZdK7cAfrpNPS1oBOVyrT7+ejHjwY9fTegIeAlcezF3R4pYE5Y4bmsiCsZac2HNb5BK00lymzq/654DaHLOp7+umHS3FTng8Tj1enatq6Nkg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com; 
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=AxN35S/dYf7OibS2xBWjRPIzspyvrcXyXJHdGLq1N7E=;
 b=gChYB3y2IBPeuh3uL4Sk/SkGfk5ICaGPZRSKYfa/pRhMYFVcmfH9G5b8DPGKG/RzX8vmV6or40jo8LP0D3z94IF3S1iXS1Ruov/E3Byoecz7f0AjhnfzPKItFY1cCbvuCDVc4pbIqaWYGe/Y8s6E/T1yeRNIPhh7ifq6u65gdEQNrcyWTodTJNvYngiLGMMAoeXLseJGBxcvWTJ6Wrx0cdF1PF/MiHDdoroVLbJxIiKRMsyZsvPrM+k13E+gdbqcTJB4VLnEUWIrun7MXxKSZyERaNr2rQqSQnr3l4v+rTJ5MEPDNniEVB11JZtIUPaJTOYOOJU0gOZ+aJottEb1GA==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=whamcloud.com; dmarc=pass action=none
 header.from=whamcloud.com; dkim=pass header.d=whamcloud.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=whamcloud.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=AxN35S/dYf7OibS2xBWjRPIzspyvrcXyXJHdGLq1N7E=;
 b=rM8tYsxYHijyxVPocAbwjcM/JXNOevluO031kG5qboM829/wC+40ZMHwVwyZ9NmVXID+YW7kBohzl1lb5edTD+KmdskFZmBqiZQWnmkR566p9Phbwvb75ve5DtoZN0bZLdmOOWrLyhPVDtW42fr95NWvkmraVSLExMfGeSegOo8=
Received: from DM4PR19MB6224.namprd19.prod.outlook.com (2603:10b6:8:aa::5) by
 PH7PR19MB7075.namprd19.prod.outlook.com (2603:10b6:510:20a::20) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.9031.21; Mon, 25 Aug
 2025 16:51:51 +0000
Received: from DM4PR19MB6224.namprd19.prod.outlook.com
 ([fe80::dab6:29b:ed60:1859]) by DM4PR19MB6224.namprd19.prod.outlook.com
 ([fe80::dab6:29b:ed60:1859%4]) with mapi id 15.20.9052.014; Mon, 25 Aug 2025
 16:51:50 +0000
To: =?utf-8?B?R8O2dHogV2FzY2hr?= <goetz.waschk@gmail.com>,
 "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>
Thread-Topic: [lustre-devel] Git server down?
Thread-Index: AQHcFdmb4X7+5PZPUkuOmDfwbGYPtLRzIA4A
Date: Mon, 25 Aug 2025 16:51:50 +0000
Message-ID: <0BA8A991-6722-4C3D-B98C-5DC2F7365CBC@whamcloud.com>
References: <CACd6u-qfd=cyJBEmM7TwWM=++AMT8KmVu=97EX24jiukzDPJRA@mail.gmail.com>
In-Reply-To: <CACd6u-qfd=cyJBEmM7TwWM=++AMT8KmVu=97EX24jiukzDPJRA@mail.gmail.com>
Accept-Language: en-CA, en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
user-agent: Microsoft-MacOutlook/16.100.25081721
authentication-results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=whamcloud.com;
x-ms-publictraffictype: Email
x-ms-traffictypediagnostic: DM4PR19MB6224:EE_|PH7PR19MB7075:EE_
x-ms-office365-filtering-correlation-id: 9f63c439-f816-403b-ab4e-08dde3f7b038
x-ms-exchange-senderadcheck: 1
x-ms-exchange-antispam-relay: 0
x-microsoft-antispam: BCL:0;
 ARA:13230040|366016|1800799024|376014|7053199007|13003099007|8096899003|38070700018;
x-microsoft-antispam-message-info: =?utf-8?B?eUx5eXVoc1QrbVM4aTRIeGFsSU1xSnpnRjJrYzZScmJDcE9sN3NBcVdrU0lX?=
 =?utf-8?B?ZGhwcHZpY1FHSVZFMUF0dmsrTThkZjhiL3lIM3FNQi9OSzNXV1M3WVBJbS9W?=
 =?utf-8?B?QXh1ZGtYbjNOcHk3aGpZWTRyY2RBYW9qL0VYTWIyT1FIV2pzZmpubG9SQ2xO?=
 =?utf-8?B?RURiNzlSTXV3WTJEYmU4a3lPdUcyVDNPNWU1ZEZtSDFLeDR2R1dWTnF1MUl6?=
 =?utf-8?B?UFlzTzVLdFIzcDBrUU9yaEpndGlXV1ZxSlovZkcvRlliZkc1czhtWm5yUmNX?=
 =?utf-8?B?VEhIa0U5OVpEdDJPKzQ5MjlNajdycktFZ04rekZQcGtaZjN3YmtPRFpJK2lX?=
 =?utf-8?B?TUt5Q1hKcmgySmNNc3RYcnZvcWxaMUxEVy9qSWUyTTA2TlF1LzRkbUd1cTYv?=
 =?utf-8?B?VWl3VlF3anJoeEU5c25SWEc2czViSFlWdUIrRjVPQmh3SDlvaG5lSXA1c0xF?=
 =?utf-8?B?OXQzV0Y5Y2M3ekZMeWdlNE1hTkxrczFPVVZVeUZJWDNhVDRzMkVlWTJYQ0ZL?=
 =?utf-8?B?RnNEMzVoSVc2cCttUHI0YmdHTm1ZbUtPNHhkL2Y0aDM4Uk5HZnlQb1RjRVdx?=
 =?utf-8?B?TFFiMWptSXBRL1JDTUFEMi9tcjdZVEJIdE9HbmI0QkpqajRaUHd2UGJjSGox?=
 =?utf-8?B?U1FsVzlpQVRKQkVpSW1iMXRRWkJRY1JGZFY3R0dXOWtOOHBhRmJubHJUMHNN?=
 =?utf-8?B?WFY5cUlycXMzYzdIRGRLRDRXU3RJTGI3ckZDenU0Nit6NVBRcXRoQjhuNGpS?=
 =?utf-8?B?YlF3cTROdTlPU2YwbTFlS0VyaldVdEYvUHZZWTFaQTNpdDZIYjM5K2x6bERp?=
 =?utf-8?B?aEVjV2wxR3paRjQ3Skx6ZG5ob1lPSjE0cGpiWXduZ0pKUkpnSXlMZnZaSGZw?=
 =?utf-8?B?S1AvMnRDZFZMNDJkUmNOQmE4eE9LR1piVWZ2T21WaXA4MW05TkN0Vm10Y1V1?=
 =?utf-8?B?d09kandHZEMyYllSeldjV3RVdjMrajhuUkpsS0NuSHRuWEJHY05yd1ZTR2pS?=
 =?utf-8?B?Ym9UZjAweGw2MHo3d3FkUzg1TE1mdldXSU1UNmRHd1FOS3o2dlZGbW5zVTlu?=
 =?utf-8?B?MEhTVDBGRHI2MGgrTE5YNWFubVRzd1RZdUY2WG8vQTFmdFpyNTJQRFEweFc1?=
 =?utf-8?B?bWFWVndwMW03NzI4T2kvR1lQeWh3VnVYbjg2RUdiUHg0T216VjRMVWI4djZJ?=
 =?utf-8?B?V0RoZ2tYdnZtL0FaRlJkT3UzQitjOWg2Z21PVFJjZmIxRVFoajlqZG5tcEQ2?=
 =?utf-8?B?V283KzhJVGxyUlF0dkFjcmd6Vnh4NmtONXVZZUFuLy96eEJsSTBKUzlWVDZY?=
 =?utf-8?B?bFF3VnJXVUY5TCtTVUVmQkM1cnJKWU43a2RTek1HUGViSWdva1AwcjNvU1Mz?=
 =?utf-8?B?RzJQaUs0TUFyRExBanlHUy9lRHdRYWYwcWFuZDdSM1U4MWduZ00wNjMvZG1j?=
 =?utf-8?B?SG5Wczg4bGczSzNHMzdpVHRyazVPWktVMEViWW41M0VhZEg4WTNieWtITDNB?=
 =?utf-8?B?b3VmL2JsZXdkQnZ2eDAyMzcxYnBTSkZRb0Z3VTNrS2lGOVpNUXhodm9iODdJ?=
 =?utf-8?B?ajkxZEF0WTJzMC91ZlZCWTgxVG9pTHdDY1dkNUJvaEhDOVh1ZUpCMk8rekxV?=
 =?utf-8?B?anpiMnR6aW02RGtqZ3BsSlN1Y3JLdVBYU0VhbHVFMTVkdFF0SmhXZkxkeXVS?=
 =?utf-8?B?Z0VTbXpwUFhhaVlXT2lLOGpZWU1zQm5vNzFpNkZXSmIrSWdmaTZ1cUR1cEFG?=
 =?utf-8?B?UHozRkxaRDVjR0JoWjVUekNSWEplYmhTZzZoV2pBTjU0Z1FKODlUbHRGQ28x?=
 =?utf-8?B?WElYbFdhK0xsdjZZYjhwaExVVnVYR0h0NFh0TDFqMVBQWjlwUzZiL3ZhTVVI?=
 =?utf-8?B?M3YrcnNwSldMRmw5VENHWDk4eHFXbkY0NlovbWVtam8yMllhYS9WSC9TcWw1?=
 =?utf-8?Q?ujxhQLUVxiY=3D?=
x-forefront-antispam-report: CIP:255.255.255.255; CTRY:; LANG:en; SCL:1; SRV:;
 IPV:NLI; SFV:NSPM; H:DM4PR19MB6224.namprd19.prod.outlook.com; PTR:; CAT:NONE;
 SFS:(13230040)(366016)(1800799024)(376014)(7053199007)(13003099007)(8096899003)(38070700018);
 DIR:OUT; SFP:1102; 
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0: =?utf-8?B?ODhmWUhxeHpUZU8vWFp0dmt4QkVTNUFmQ1Znckg4TVpNbGNNS2NJUlQ5V2RY?=
 =?utf-8?B?SzdSS0hKLzlHOHNTamdvMkRHTlNLejJOQW9IWDdxTHBNT0I4Tm11WnFPNFVN?=
 =?utf-8?B?R1dPTlRjbGoyS0dhT3VHYXhWS1JXcUVOOTlnbDhxN2VyTkcrVU5iU2tnOUw2?=
 =?utf-8?B?aUtFWHNuNHhGRURITXd4WTFxT0F5bm0wYmc5anpad0dHYk5RSHBPNnBvMDJC?=
 =?utf-8?B?Q1NnaWorU2pTM3BSVWh2eGROYU5MVGE5bWp6M2locjcxbTJxUUlCQzBwa25H?=
 =?utf-8?B?N2tZZ0RFbmhBKzBFNjlIQ29lbC9RT3BHMGU0WjRSVnBDWkc4VStMN3BOcFBT?=
 =?utf-8?B?SVdwcmVsY1ZiRkZlaFFDcmRVcDduRytCcllNS1ZDUkg3NnhOc2lpc0VSaHB0?=
 =?utf-8?B?VzQ0cVRoeHlwWWF5YjNDTit1STNkQXhabmk4U1NnMGNDM0c0UHE3dEQxelNo?=
 =?utf-8?B?dkxteDE3M2VhUTRMRi8yVFVHdnZtVEFOR0tVNWhCbU9JdTVFN0c4R042ZEh1?=
 =?utf-8?B?YTZpd3Q1bVVMQTNUck5YdWlJZ3Z3dFYra3lkMndvTlozWENYNnQ0djExVjZj?=
 =?utf-8?B?OVE3SjVRT1NGRGVKZ1RSUUFzVXJrNy8za1ZjUGZTejJWUU5adS8wOWE2RHJ3?=
 =?utf-8?B?a0NUQ3daVXJsREtFWHdGSEVzakZ3c0ZKUk9Oc25NeGtqbVhnQjFpcE9RYXRu?=
 =?utf-8?B?NGZMejU2TERITW81R0hRcjNjVVdnMEZ4NXprWDBON3cvaHYxM0lEYjVtWU5v?=
 =?utf-8?B?a2w3K1hOcElDWE41SWsveUltYy82bHFJVkdSdExrSXZQVVdFb2xrVjZsdGV6?=
 =?utf-8?B?UjVDMGE5WE4zcHk4VWlMdDJMRitzTFRORWdGRUh6TFNoeGZmckp3R3Q4VmNT?=
 =?utf-8?B?K21TN0lYdzJZeUpsalNoUzhXTFZvcVpkamxXaXArZXVqakwrcFViZzhHVGh4?=
 =?utf-8?B?MSs5KzVIRzVKNkdyY3RhdDJsQkYvcDc3a1RtcFdUcXVFb1ZvZ3RJQkZXY0lH?=
 =?utf-8?B?L2pNNlRFMjNXZ3Zmd2xPNVFLS0lKaGMrZVo4Qlc2QnUxak1CUlU4YVZSRmJD?=
 =?utf-8?B?ZUVoSTBHNUJCelBUVm11cmNrMGFMaWcyeG02b3FGR1hMQjlHOC9GTzJXOFJK?=
 =?utf-8?B?VXdUWGlWalRyZVVBNzFEUnF6aTFOSU9Ma3phYm1NaFdxbkdPNmJLdVlIb0s1?=
 =?utf-8?B?NXM1c01nTDRvUWJGM1I4KzVZK3ZrUis3aitsZFZjZHVSQ3M0T1ZWSmdXMGVP?=
 =?utf-8?B?dGQydHNlaXJnWlZYR3ltTFdaeE5GUE9OdnVvQnJWem1KRTBSbHMwRDdmWjlH?=
 =?utf-8?B?QmlGRFk4NUIyZng1VDQxUXdQRFZ2S1dvVEhnbGY5L1BoTG50VTlCa2RBZll6?=
 =?utf-8?B?Tzk4eFZMOWpWN1cxbGg5SG5OZnBqaDcwZDV3ejlCa2ppSTQzYmZCaVdZM096?=
 =?utf-8?B?WndkUHdQUGliS0Q4RUdzSzRzYnBINHdSWUNXT1k1SXRZQjU3aDVZU1FJRWRw?=
 =?utf-8?B?YkFUSFFTYmdRQjlyQmxHWitnNW1HMnhMMStCWFhvaTBzMUtpcHhCKzBqQlBS?=
 =?utf-8?B?eXU5QlJFMkpyTXNQMDZxNjBuYk1mTlhJaWlINWNBWjhPQVRIdFRpd3Y5elFu?=
 =?utf-8?B?dUFGN0ZKem5Lbi9BNWFmbzJ6YUdyYzg3QnlSZjRLVXNDaDdITnJwLzI0KzVa?=
 =?utf-8?B?cVYvYUFqTkczMWU1ejRzRVMxYkZRcXBLTnd6Tk5KdUZ0R1BWMzdMZWN2V2Rz?=
 =?utf-8?B?cTdHbnUwSmRKcXJkK0Mxc2tudUtxYm1aTVplQWxGazZuY0hzZU1FdUxXV3Rm?=
 =?utf-8?B?T1JNQkdCMGV6T2RoNzFadFZKK0tmcG9uMWorNW9BV3hVc3BFeHhtVTlxR1Rn?=
 =?utf-8?B?d1UwMW9WV0s4THNuNTVaSGdBT2dzYWY2cGtxZnE4cEUzRmNpQXBrVHAzY1VX?=
 =?utf-8?B?OEhjTVJmcUN3cjFVZ2xHZXA4bnovYnluMWEwUHdEKzA4TDRyZldQRmlUaUF3?=
 =?utf-8?B?aCtUcno2S2pmSWpPaXJvQ2x4T3FkMkdpcnF4RklqTjBGNVhxVDhJenU5SVJ0?=
 =?utf-8?B?M0FlcnAxMHd6KzNYVVVnOTdTTHBPVFBLaHdGNlVUUWMrWTRNc0NoRlV2eWJp?=
 =?utf-8?Q?IR8DjmLZadsj9xgRztW5L63TD?=
MIME-Version: 1.0
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-0: WDzgjVE5E90MxYCIjlvOIK48/0BVB/Lch+DaKnPZkwqD97jIfUS6uzLh5xibMHsJhYOmWfveiooXYJmT2skBLVTIqOadYTnWwk8FbKjrRFklkfgQz6LVRynJvQ1W7JxoYJZjRMq1O+vhs0M71hRWYkfJr3gBMUQh5UiBMb2We7PYO4G64eVwHi8MvAK6I2fvYKY52K836BhIDnPU32se62GXXpBTXa1sObr+Njxk6TPWsIPmB8TAs7XqF3uFNgO7FWj+phy6SXErDE5eXilP5ql83313NGrhZfCts3BQrwnJ9g2YuIlPtEJLcMmDb6vpDhCn5KDe3ILLoJ1JzP3pMklEk9PXj0P7eTC2lZX2Pl/IYd/xce+RRMpbrKOWqLSvvpL1ZdN4uS63eW8k0De9b/mj8F4alJJbJ5X0Ih0nPZJ6HM5JQ8zGpLyhaUlKOfTj22sYNotUBFM5Shjevxwp5lzWYVkV+iLjnOtyCgLdD3dYgpxVGxBJjPDb8SKKnUMBROpbGVlLG0NLj7KQ+R3i+YhpbVFizPVZ3dxod6PhtcLlo5z0nrxsH4qSM3JIiV/2HgzMaTrtUCwMu0fjeGG5dG2ZnNjV4pq7BeX34VrIwmRGvFUA8KVCgKTRJdxUCvgTRvuwHVHojWGY4D6VYTukVk9Mdx7WcnUPCcQqkgtVDV8=
X-OriginatorOrg: whamcloud.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: DM4PR19MB6224.namprd19.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 9f63c439-f816-403b-ab4e-08dde3f7b038
X-MS-Exchange-CrossTenant-originalarrivaltime: 25 Aug 2025 16:51:50.9050 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 753b6e26-6fd3-43e6-8248-3f1735d59bb4
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: DGTvnYpQWuBzP2t5SMOA8DYAJJY4G5V6zYCvZeMEWDYJPFeFsy/TyUCyyisqTwP3
X-MS-Exchange-Transport-CrossTenantHeadersStamped: PH7PR19MB7075
X-BESS-ID: 1756140715-111696-7608-11195-1
X-BESS-VER: 2019.1_20250807.1754
X-BESS-Apparent-Source-IP: 40.107.94.90
X-BESS-Parts: H4sIAAAAAAACAzXLMQ7CMAyF4bt47oBjO7F7FcRg7FRdEAMZkFDvToZ2efr1pO
 /+g/4dsMKYu8D7AysWpVn7PFsWa52ceRP26oQRXCXDBaNkwLFcfh+v05OqnZ6Y1FBqIf
 Ut0cwt+i2pSZWnGcPx+AO08E7ygQAAAA==
X-BESS-Outbound-Spam-Score: 0.00
X-BESS-Outbound-Spam-Report: Code version 3.2,
 rules version 3.2.2.267021 [from 
 cloudscan15-24.us-east-2a.ess.aws.cudaops.com]
 Rule breakdown below
 pts rule name              description
 ---- ---------------------- --------------------------------
 0.00 HTML_MESSAGE           BODY: HTML included in message 
 0.00 BSF_BESS_OUTBOUND      META: BESS Outbound 
X-BESS-Outbound-Spam-Status: SCORE=0.00 using account:ESS124931 scores of
 KILL_LEVEL=7.0 tests=HTML_MESSAGE, BSF_BESS_OUTBOUND
X-BESS-BRTS-Status: 1
Subject: Re: [lustre-devel] Git server down?
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
Reply-To: Peter Jones <pjones@whamcloud.com>
Content-Type: multipart/mixed; boundary="===============8891203552705145872=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============8891203552705145872==
Content-Language: en-US
Content-Type: multipart/alternative;
	boundary="_000_0BA8A99167224C3DB98C5DC2F7365CBCwhamcloudcom_"

--_000_0BA8A99167224C3DB98C5DC2F7365CBCwhamcloudcom_
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64

R8O2dHoNCg0KU29tZSBleHRyYSBzZWN1cml0eSB3YXMgcmVjZW50bHkgYWRkZWQgYW5kIGl0IHNl
ZW1zIHRvIGhhdmUgY2F1c2UgaXNzdWVzIGZvciBhIGNvdXBsZSBvZiBwZW9wbGUuIE90aGVycyBp
bXBhY3RlZCBoYXZlIGZvdW5kIHN3aXRjaGluZyB0byB1c2UgdGhlIGdpdGh1YiBtaXJyb3IgLSBo
dHRwczovL2dpdGh1Yi5jb20vbHVzdHJlL2x1c3RyZS1yZWxlYXNlIC0gd2FzIGEgc2ltcGxlIHdh
eSB0byBzaWRlc3RlcCBwcm9ibGVtcy4NCg0KUGV0ZXINCg0KRnJvbTogbHVzdHJlLWRldmVsIDxs
dXN0cmUtZGV2ZWwtYm91bmNlc0BsaXN0cy5sdXN0cmUub3JnPiBvbiBiZWhhbGYgb2YgR8O2dHog
V2FzY2hrIHZpYSBsdXN0cmUtZGV2ZWwgPGx1c3RyZS1kZXZlbEBsaXN0cy5sdXN0cmUub3JnPg0K
UmVwbHktVG86IEfDtnR6IFdhc2NoayA8Z29ldHoud2FzY2hrQGdtYWlsLmNvbT4NCkRhdGU6IE1v
bmRheSwgQXVndXN0IDI1LCAyMDI1IGF0IDk6MDLigK9BTQ0KVG86ICJsdXN0cmUtZGV2ZWxAbGlz
dHMubHVzdHJlLm9yZyIgPGx1c3RyZS1kZXZlbEBsaXN0cy5sdXN0cmUub3JnPg0KU3ViamVjdDog
W2x1c3RyZS1kZXZlbF0gR2l0IHNlcnZlciBkb3duPw0KDQpIaSBldmVyeW9uZSwNCg0KSSBjYW5u
b3QgYWNjZXNzIHRoZSBnaXQgc2VydmVyOg0KDQojIGdpdCBjbG9uZSAtYiBtYXN0ZXIgZ2l0Oi8v
Z2l0LndoYW1jbG91ZC5jb20vZnMvbHVzdHJlLXJlbGVhc2UuZ2l0PGh0dHA6Ly9naXQud2hhbWNs
b3VkLmNvbS9mcy9sdXN0cmUtcmVsZWFzZS5naXQ+IGx1c3RyZS1tYXN0ZXINCkNsb25pbmcgaW50
byAnbHVzdHJlLW1hc3RlcicuLi4NCmZhdGFsOiB1bmFibGUgdG8gY29ubmVjdCB0byBnaXQud2hh
bWNsb3VkLmNvbTxodHRwOi8vZ2l0LndoYW1jbG91ZC5jb20+Og0KZ2l0LndoYW1jbG91ZC5jb208
aHR0cDovL2dpdC53aGFtY2xvdWQuY29tPlswOiAyNjA2OjQ3MDA6MzAzMTo6NjgxNTozMGY2XTog
ZXJybm89Q29ubmVjdGlvbiB0aW1lZCBvdXQNCmdpdC53aGFtY2xvdWQuY29tPGh0dHA6Ly9naXQu
d2hhbWNsb3VkLmNvbT5bMTogMjYwNjo0NzAwOjMwMzA6OmFjNDM6OGFmNV06IGVycm5vPUNvbm5l
Y3Rpb24gdGltZWQgb3V0DQpnaXQud2hhbWNsb3VkLmNvbTxodHRwOi8vZ2l0LndoYW1jbG91ZC5j
b20+WzI6IDEwNC4yMS40OC4yNDZdOiBlcnJubz1Db25uZWN0aW9uIHRpbWVkIG91dA0KZ2l0Lndo
YW1jbG91ZC5jb208aHR0cDovL2dpdC53aGFtY2xvdWQuY29tPlszOiAxNzIuNjcuMTM4LjI0NV06
IGVycm5vPUNvbm5lY3Rpb24gdGltZWQgb3V0DQoNClJlZ2FyZHMsDQpHw7Z0eiBXYXNjaGsNCg==

--_000_0BA8A99167224C3DB98C5DC2F7365CBCwhamcloudcom_
Content-Type: text/html; charset="utf-8"
Content-ID: <159E86BF40F340418177BFA0030742DE@namprd19.prod.outlook.com>
Content-Transfer-Encoding: base64

PGh0bWwgeG1sbnM6bz0idXJuOnNjaGVtYXMtbWljcm9zb2Z0LWNvbTpvZmZpY2U6b2ZmaWNlIiB4
bWxuczp3PSJ1cm46c2NoZW1hcy1taWNyb3NvZnQtY29tOm9mZmljZTp3b3JkIiB4bWxuczptPSJo
dHRwOi8vc2NoZW1hcy5taWNyb3NvZnQuY29tL29mZmljZS8yMDA0LzEyL29tbWwiIHhtbG5zPSJo
dHRwOi8vd3d3LnczLm9yZy9UUi9SRUMtaHRtbDQwIj4NCjxoZWFkPg0KPG1ldGEgaHR0cC1lcXVp
dj0iQ29udGVudC1UeXBlIiBjb250ZW50PSJ0ZXh0L2h0bWw7IGNoYXJzZXQ9dXRmLTgiPg0KPG1l
dGEgbmFtZT0iR2VuZXJhdG9yIiBjb250ZW50PSJNaWNyb3NvZnQgV29yZCAxNSAoZmlsdGVyZWQg
bWVkaXVtKSI+DQo8c3R5bGU+PCEtLQ0KLyogRm9udCBEZWZpbml0aW9ucyAqLw0KQGZvbnQtZmFj
ZQ0KCXtmb250LWZhbWlseToiQ2FtYnJpYSBNYXRoIjsNCglwYW5vc2UtMToyIDQgNSAzIDUgNCA2
IDMgMiA0O30NCkBmb250LWZhY2UNCgl7Zm9udC1mYW1pbHk6Q2FsaWJyaTsNCglwYW5vc2UtMToy
IDE1IDUgMiAyIDIgNCAzIDIgNDt9DQpAZm9udC1mYWNlDQoJe2ZvbnQtZmFtaWx5OkFwdG9zOw0K
CXBhbm9zZS0xOjIgMTEgNiA0IDIgMiAyIDIgMiA0O30NCi8qIFN0eWxlIERlZmluaXRpb25zICov
DQpwLk1zb05vcm1hbCwgbGkuTXNvTm9ybWFsLCBkaXYuTXNvTm9ybWFsDQoJe21hcmdpbjowaW47
DQoJZm9udC1zaXplOjEyLjBwdDsNCglmb250LWZhbWlseToiQXB0b3MiLHNhbnMtc2VyaWY7fQ0K
YTpsaW5rLCBzcGFuLk1zb0h5cGVybGluaw0KCXttc28tc3R5bGUtcHJpb3JpdHk6OTk7DQoJY29s
b3I6Ymx1ZTsNCgl0ZXh0LWRlY29yYXRpb246dW5kZXJsaW5lO30NCnNwYW4uRW1haWxTdHlsZTE4
DQoJe21zby1zdHlsZS10eXBlOnBlcnNvbmFsLXJlcGx5Ow0KCWZvbnQtZmFtaWx5OiJBcHRvcyIs
c2Fucy1zZXJpZjsNCgljb2xvcjp3aW5kb3d0ZXh0O30NCi5Nc29DaHBEZWZhdWx0DQoJe21zby1z
dHlsZS10eXBlOmV4cG9ydC1vbmx5Ow0KCWZvbnQtc2l6ZToxMC4wcHQ7DQoJbXNvLWxpZ2F0dXJl
czpub25lO30NCkBwYWdlIFdvcmRTZWN0aW9uMQ0KCXtzaXplOjguNWluIDExLjBpbjsNCgltYXJn
aW46MS4waW4gMS4waW4gMS4waW4gMS4waW47fQ0KZGl2LldvcmRTZWN0aW9uMQ0KCXtwYWdlOldv
cmRTZWN0aW9uMTt9DQotLT48L3N0eWxlPg0KPC9oZWFkPg0KPGJvZHkgbGFuZz0iRU4tVVMiIGxp
bms9ImJsdWUiIHZsaW5rPSJwdXJwbGUiIHN0eWxlPSJ3b3JkLXdyYXA6YnJlYWstd29yZCI+DQo8
ZGl2IGNsYXNzPSJXb3JkU2VjdGlvbjEiPg0KPHAgY2xhc3M9Ik1zb05vcm1hbCI+R8O2dHo8bzpw
PjwvbzpwPjwvcD4NCjxwIGNsYXNzPSJNc29Ob3JtYWwiPjxvOnA+Jm5ic3A7PC9vOnA+PC9wPg0K
PHAgY2xhc3M9Ik1zb05vcm1hbCI+U29tZSBleHRyYSBzZWN1cml0eSB3YXMgcmVjZW50bHkgYWRk
ZWQgYW5kIGl0IHNlZW1zIHRvIGhhdmUgY2F1c2UgaXNzdWVzIGZvciBhIGNvdXBsZSBvZiBwZW9w
bGUuIE90aGVycyBpbXBhY3RlZCBoYXZlIGZvdW5kIHN3aXRjaGluZyB0byB1c2UgdGhlIGdpdGh1
YiBtaXJyb3IgLQ0KPGEgaHJlZj0iaHR0cHM6Ly9naXRodWIuY29tL2x1c3RyZS9sdXN0cmUtcmVs
ZWFzZSI+aHR0cHM6Ly9naXRodWIuY29tL2x1c3RyZS9sdXN0cmUtcmVsZWFzZTwvYT4gLSB3YXMg
YSBzaW1wbGUgd2F5IHRvIHNpZGVzdGVwIHByb2JsZW1zLjxvOnA+PC9vOnA+PC9wPg0KPHAgY2xh
c3M9Ik1zb05vcm1hbCI+PG86cD4mbmJzcDs8L286cD48L3A+DQo8cCBjbGFzcz0iTXNvTm9ybWFs
Ij5QZXRlcjxzcGFuIHN0eWxlPSJmb250LXNpemU6MTEuMHB0Ij48bzpwPjwvbzpwPjwvc3Bhbj48
L3A+DQo8cCBjbGFzcz0iTXNvTm9ybWFsIj48c3BhbiBzdHlsZT0iZm9udC1zaXplOjExLjBwdCI+
PG86cD4mbmJzcDs8L286cD48L3NwYW4+PC9wPg0KPGRpdiBzdHlsZT0iYm9yZGVyOm5vbmU7Ym9y
ZGVyLXRvcDpzb2xpZCAjQjVDNERGIDEuMHB0O3BhZGRpbmc6My4wcHQgMGluIDBpbiAwaW4iPg0K
PHAgY2xhc3M9Ik1zb05vcm1hbCI+PGI+PHNwYW4gc3R5bGU9ImZvbnQtZmFtaWx5OiZxdW90O0Nh
bGlicmkmcXVvdDssc2Fucy1zZXJpZjtjb2xvcjpibGFjayI+RnJvbToNCjwvc3Bhbj48L2I+PHNw
YW4gc3R5bGU9ImZvbnQtZmFtaWx5OiZxdW90O0NhbGlicmkmcXVvdDssc2Fucy1zZXJpZjtjb2xv
cjpibGFjayI+bHVzdHJlLWRldmVsICZsdDtsdXN0cmUtZGV2ZWwtYm91bmNlc0BsaXN0cy5sdXN0
cmUub3JnJmd0OyBvbiBiZWhhbGYgb2YgR8O2dHogV2FzY2hrIHZpYSBsdXN0cmUtZGV2ZWwgJmx0
O2x1c3RyZS1kZXZlbEBsaXN0cy5sdXN0cmUub3JnJmd0Ozxicj4NCjxiPlJlcGx5LVRvOiA8L2I+
R8O2dHogV2FzY2hrICZsdDtnb2V0ei53YXNjaGtAZ21haWwuY29tJmd0Ozxicj4NCjxiPkRhdGU6
IDwvYj5Nb25kYXksIEF1Z3VzdCAyNSwgMjAyNSBhdCA5OjAy4oCvQU08YnI+DQo8Yj5UbzogPC9i
PiZxdW90O2x1c3RyZS1kZXZlbEBsaXN0cy5sdXN0cmUub3JnJnF1b3Q7ICZsdDtsdXN0cmUtZGV2
ZWxAbGlzdHMubHVzdHJlLm9yZyZndDs8YnI+DQo8Yj5TdWJqZWN0OiA8L2I+W2x1c3RyZS1kZXZl
bF0gR2l0IHNlcnZlciBkb3duPzxvOnA+PC9vOnA+PC9zcGFuPjwvcD4NCjwvZGl2Pg0KPGRpdj4N
CjxwIGNsYXNzPSJNc29Ob3JtYWwiPjxvOnA+Jm5ic3A7PC9vOnA+PC9wPg0KPC9kaXY+DQo8ZGl2
Pg0KPHAgY2xhc3M9Ik1zb05vcm1hbCI+SGkgZXZlcnlvbmUsPG86cD48L286cD48L3A+DQo8ZGl2
Pg0KPHAgY2xhc3M9Ik1zb05vcm1hbCI+PG86cD4mbmJzcDs8L286cD48L3A+DQo8L2Rpdj4NCjxk
aXY+DQo8cCBjbGFzcz0iTXNvTm9ybWFsIj5JIGNhbm5vdCBhY2Nlc3MgdGhlIGdpdCBzZXJ2ZXI6
PG86cD48L286cD48L3A+DQo8L2Rpdj4NCjxkaXY+DQo8cCBjbGFzcz0iTXNvTm9ybWFsIj48bzpw
PiZuYnNwOzwvbzpwPjwvcD4NCjwvZGl2Pg0KPGRpdj4NCjxwIGNsYXNzPSJNc29Ob3JtYWwiPiMg
Z2l0IGNsb25lIC1iIG1hc3RlciBnaXQ6Ly88YSBocmVmPSJodHRwOi8vZ2l0LndoYW1jbG91ZC5j
b20vZnMvbHVzdHJlLXJlbGVhc2UuZ2l0Ij5naXQud2hhbWNsb3VkLmNvbS9mcy9sdXN0cmUtcmVs
ZWFzZS5naXQ8L2E+IGx1c3RyZS1tYXN0ZXI8bzpwPjwvbzpwPjwvcD4NCjwvZGl2Pg0KPGRpdj4N
CjxwIGNsYXNzPSJNc29Ob3JtYWwiPkNsb25pbmcgaW50byAnbHVzdHJlLW1hc3RlcicuLi48YnI+
DQpmYXRhbDogdW5hYmxlIHRvIGNvbm5lY3QgdG8gPGEgaHJlZj0iaHR0cDovL2dpdC53aGFtY2xv
dWQuY29tIj5naXQud2hhbWNsb3VkLmNvbTwvYT46PGJyPg0KPGEgaHJlZj0iaHR0cDovL2dpdC53
aGFtY2xvdWQuY29tIj5naXQud2hhbWNsb3VkLmNvbTwvYT5bMDogMjYwNjo0NzAwOjMwMzE6OjY4
MTU6MzBmNl06IGVycm5vPUNvbm5lY3Rpb24gdGltZWQgb3V0PGJyPg0KPGEgaHJlZj0iaHR0cDov
L2dpdC53aGFtY2xvdWQuY29tIj5naXQud2hhbWNsb3VkLmNvbTwvYT5bMTogMjYwNjo0NzAwOjMw
MzA6OmFjNDM6OGFmNV06IGVycm5vPUNvbm5lY3Rpb24gdGltZWQgb3V0PGJyPg0KPGEgaHJlZj0i
aHR0cDovL2dpdC53aGFtY2xvdWQuY29tIj5naXQud2hhbWNsb3VkLmNvbTwvYT5bMjogMTA0LjIx
LjQ4LjI0Nl06IGVycm5vPUNvbm5lY3Rpb24gdGltZWQgb3V0PGJyPg0KPGEgaHJlZj0iaHR0cDov
L2dpdC53aGFtY2xvdWQuY29tIj5naXQud2hhbWNsb3VkLmNvbTwvYT5bMzogMTcyLjY3LjEzOC4y
NDVdOiBlcnJubz1Db25uZWN0aW9uIHRpbWVkIG91dDxvOnA+PC9vOnA+PC9wPg0KPC9kaXY+DQo8
ZGl2Pg0KPHAgY2xhc3M9Ik1zb05vcm1hbCI+PG86cD4mbmJzcDs8L286cD48L3A+DQo8L2Rpdj4N
CjxkaXY+DQo8cCBjbGFzcz0iTXNvTm9ybWFsIj5SZWdhcmRzLDxvOnA+PC9vOnA+PC9wPg0KPC9k
aXY+DQo8ZGl2Pg0KPHAgY2xhc3M9Ik1zb05vcm1hbCI+R8O2dHogV2FzY2hrPG86cD48L286cD48
L3A+DQo8L2Rpdj4NCjwvZGl2Pg0KPC9kaXY+DQo8L2JvZHk+DQo8L2h0bWw+DQo=

--_000_0BA8A99167224C3DB98C5DC2F7365CBCwhamcloudcom_--

--===============8891203552705145872==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============8891203552705145872==--
