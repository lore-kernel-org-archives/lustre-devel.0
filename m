Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 311AFC02194
	for <lustre-devel@archiver.kernel.org>; Tue,  4 Feb 2025 17:34:36 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4YnVpc3n6Cz1xPd;
	Tue, 04 Feb 2025 09:34:00 -0800 (PST)
Received: from outbound-ip168a.ess.barracuda.com
 (outbound-ip168a.ess.barracuda.com [209.222.82.36])
 (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4YnVnz2WWpz1xNq
 for <lustre-devel@lists.lustre.org>; Tue, 04 Feb 2025 09:33:27 -0800 (PST)
Received: from NAM10-DM6-obe.outbound.protection.outlook.com
 (mail-dm6nam10lp2048.outbound.protection.outlook.com [104.47.58.48]) by
 mx-outbound14-132.us-east-2a.ess.aws.cudaops.com (version=TLSv1.2
 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
 Tue, 04 Feb 2025 17:33:18 +0000
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=xDKydGDkFFAK/1Ev4Da96S6YDYvFGWKfeZXMpEbjUEiBzg/Mwd57eOsjTceTAVt0Ym8If4xt7PStYLVWp9BXJplHd9ivqQMQU2n3OpW8NzeYPffcdBJwAULDkqxmpRI9KMuIK4Op1DHFCNDN1EuzAHJvy3+fSRl4OaFANKiRXxNCfmwfd/O0ozU3k80QcnFT0akGgEvVWCjvGNdypwqWYLs3PyxP2h0Wn9FECTxse9GlPOcQKpk0CRJ2FrUm91h0h4p0iBSZ2Ry71zq4BGX+nYxCeGRFq7QNvT/KKJBrhjtF4th5wUNRlJ9xyhkVd8mwjLqNFH5S6K+cbPLYrexFNg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com; 
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=Zi9MX1f3WVHiVeRiGDvceNeBgT2q3IP4ww5xiBQWEeI=;
 b=A2lUZyh9bmv3x+uUFxzbziNtRLJGI0cPqkLJpBpVZniK5KL9o1GeZhWulUBSPYoqkWQ08z37+sVLQM/vOViLwuH4/lIyTVUsV6O3rKXqIyU1auDva76hfUmksybLFUD/b4S1fz8fMaro0bcbRx98ZTuwefIA8FhAz2AhRSohbmSC3NW9a8UscXzxOHfGt3c0bwWrX6MVqQQP/26nXdFs9b40kREQxOYqvQkCDP0EkkJA6LK68df7CXjw0/jaG11r/1rfiLS8UHmcyIt9MF/ATYkOqXJocSESUgzhZzTlL5DJRO0p+oW6tm1He7UlQO8YzoYVSQe3kdIwzt/UJD1Bdg==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=ddn.com; dmarc=pass action=none header.from=ddn.com; dkim=pass
 header.d=ddn.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ddn.com; s=selector2; 
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=Zi9MX1f3WVHiVeRiGDvceNeBgT2q3IP4ww5xiBQWEeI=;
 b=QNr9uwyM+h5GbH4PhI4gq/CoFSTHZfzz6yIaYBv9m9iytrMwUMHWJCCJWO7AIoC/Ir/UDlHvRTvkGG1Az9cBW9qzGtpMlB8mT1g5VaEsKBvXNarEy/t6j5325nyr/wQUIIHVPFw8YXF+nfBc7DvwHj0bZj5k/fax9oUWwgRrqW0=
Received: from MW4PR19MB5630.namprd19.prod.outlook.com (2603:10b6:303:189::12)
 by DS7PR19MB6229.namprd19.prod.outlook.com (2603:10b6:8:9b::18) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.8398.18; Tue, 4 Feb
 2025 17:33:14 +0000
Received: from MW4PR19MB5630.namprd19.prod.outlook.com
 ([fe80::92fd:9b94:d9cd:81d2]) by MW4PR19MB5630.namprd19.prod.outlook.com
 ([fe80::92fd:9b94:d9cd:81d2%6]) with mapi id 15.20.8398.025; Tue, 4 Feb 2025
 17:33:14 +0000
From: Andreas Dilger <adilger@ddn.com>
To: Oleg Drokin <green@whamcloud.com>
Thread-Topic: [lustre-devel] [LSF/MM/BPF TOPIC] [DRAFT] Lustre client
 upstreaming
Thread-Index: AQHbaF06daQEbe3e/kelMir67rT0hbMbs8GAgAAqWwCAAUdfgIABebkAgAf62QCAAH1kAIAMBm2AgAASkoCAAr/pAIAAJnkAgAAH54CAAAPkgIAAAWoAgADH0wA=
Date: Tue, 4 Feb 2025 17:33:14 +0000
Message-ID: <A39FEBC6-1140-445A-83A3-7EA27AD5C356@ddn.com>
References: <7f1d21950673c3deae1e92839deb61be88d77f22.camel@whamcloud.com>
In-Reply-To: <7f1d21950673c3deae1e92839deb61be88d77f22.camel@whamcloud.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=ddn.com;
x-ms-publictraffictype: Email
x-ms-traffictypediagnostic: MW4PR19MB5630:EE_|DS7PR19MB6229:EE_
x-ms-office365-filtering-correlation-id: 7aac4d51-979e-4470-7158-08dd454200d4
x-ms-exchange-senderadcheck: 1
x-ms-exchange-antispam-relay: 0
x-microsoft-antispam: BCL:0; ARA:13230040|1800799024|376014|366016|38070700018;
x-microsoft-antispam-message-info: =?utf-8?B?WkhMandSZHBGb0x2N0U4bFNwaHh2YVBJbzNNWXU2Tmt3Z0ZEeWZXRGdVMmNP?=
 =?utf-8?B?NUMvSGVtZzM3dXh2WjhsQzlnQXlESlZOTDFuUHlMOHdGeFR5SGNNUXFvdFdi?=
 =?utf-8?B?RXM4N0pYNGg5TVM1MjUrdmtGS0VJaEpRR0ZFUWZOWVlFNHVkZmd3clNrNmpV?=
 =?utf-8?B?cFlJTmVyNXF6QnFabDkvVWIvaExkcU4wRXQxYndSenJQaVBMUWgyT0orS1RE?=
 =?utf-8?B?cEh1OTI5ZHpDeVZMcXNlMXFuVkZrUEFqbXJYV2JYc0s5TnovTE40cVF4Ryth?=
 =?utf-8?B?MGh6UHpQVXZsbzZ3NXdUNUpsUjI1T0FwN3U4MHBjWlhZQ3Nyc2xwcWlQUXBN?=
 =?utf-8?B?bGdxSHN1MkI2R2FnMXZrdE1ya2x0TE54eU1aZnJUdE9CMHJ3OTZ0SlB1Vjhn?=
 =?utf-8?B?dXNYekVuZnY5bVhObUV4Z0haQUN4UDRXZTVVYUpYOHFWaEhnaVFqVG1aVXNr?=
 =?utf-8?B?R1JsbHlKZWJZUlBYd3RJbE5SNE1wRitieGk3ZzJZZ20yckNXUDljYTJjMTJI?=
 =?utf-8?B?VXpmd0dPcUJJd2psSktFNDFxeURyR1ZXZEFmODc3RVlVZmNmL0k5NWVnME41?=
 =?utf-8?B?NTI3ZHNxWHdCMWU0bEVRRklJWmJZdWV1QmVXcW1ObG5aYzR2UmdmQTFLLy9Y?=
 =?utf-8?B?NzRmc1hNczd3OWVQSnZ3VTVUbEJ5RXpjVnJIaGxKeVVFbWtsbXE5MDRMdVhx?=
 =?utf-8?B?aWtQZEE0UEdZV0ZBOThnd1daYkdpQTE5ZVJpdFBBOGQ3bWVzSkk5SEFuSTh3?=
 =?utf-8?B?K0RWeEM4QXNpOStFd1ZCakM0eVZYblFBYUtxZDBxc0VGVGVFaVZPZU1rRWNI?=
 =?utf-8?B?NzNOK2VXT0NpSkpMSCtWNVVyNGNnbEF0c3RzSVNQMmdKNzdSQ0kxdEhOQUY1?=
 =?utf-8?B?bkdDUTNHOXgzNmFwSGxwYW1tWDkyMmxHQ2NqbUJmZUpTMUNaY3kwV0IxU3Ix?=
 =?utf-8?B?aXEzbThvR1hUR2lEd1ZpVGRzR05ZOUU4ZXdHOHBlVGNXR0FOTFhGbkxCNmFz?=
 =?utf-8?B?cms2ZzhWamg2RnNRU2RybFFaVEVFYXRNcXdqZkNhMXFkc3ZYUnFVYndNK3Ns?=
 =?utf-8?B?RjU4UGpHc1huczZ6VnVSTHJMeTQ3ZWp0Qnp5ck5Lc2UvSnNrYitqcThQYjd1?=
 =?utf-8?B?cmdHa2pVOUhUOVZoVmZjYjhzNkRscXcvbnJGZzhlcmpIc3JSQVdNalNRcjlG?=
 =?utf-8?B?MTYxcm1kbHhaQjQyYmRUODNwSjF1Znc1U0JrKzZnMjlSbzAvc1Z3STBHSDB1?=
 =?utf-8?B?RkVWcktIZjQ2V0tOdUZ3L0dVWXB6N0JGN2paRkFGZSs4dDBieHNVaWUwd3NZ?=
 =?utf-8?B?QjI1TW1DL3RXV0hObVJmM3JaQ01rQW56LzhRajRmYXlRSUlUTHZ5a1BGSU1N?=
 =?utf-8?B?d1I2T1duNVlQc1NiVXdEeUZrVC9FTENRcUFUSzV4NlRzQy9kd0I2YjhhOFhp?=
 =?utf-8?B?bVdVVWFMWHQ0RXAwcGpPbmRrNlBwczBjcHZxMzJCSTN4clBKNW40YU1mYm5z?=
 =?utf-8?B?bG5Xb09qbTU4VVhhRGUzMGhyL0p0akdLaWhacmdiVHFaNndMcGFQTkkxR0do?=
 =?utf-8?B?K1I3S2pwdDlIK3hXYU12bW9WL0RNVk9DZ3QvRTlEWk9PWUJuRzJRak1CUWdo?=
 =?utf-8?B?U1FON0pxZkc1VkNSTmxlbzVMaHRTSlVFeXVGOUJ6Yms5ci9qTTg5SlBNaVVo?=
 =?utf-8?B?RmxTa3k4OXk5ZzdaOVRNcW9zdG9RSFQxZEZ6TjlWUEpBN3cxWHVUWEwvUlRm?=
 =?utf-8?B?QmRTQTJBWEhLeVNDU1ZpTCtnL1plTDVCZFEzeDlHV3ZnWEdlMnVteENGN2FG?=
 =?utf-8?B?UnZadFdMTXdyRENVdlArY1dzRXAzZzVaTW5NMWxkTEtkak8reTVGaDBwTHBw?=
 =?utf-8?B?b2lIZXROZGhnOW9ycXJnRVZlNFZMSEpoM2lSeUhRcFBRL0E9PQ==?=
x-forefront-antispam-report: CIP:255.255.255.255; CTRY:; LANG:en; SCL:1; SRV:;
 IPV:NLI; SFV:NSPM; H:MW4PR19MB5630.namprd19.prod.outlook.com; PTR:; CAT:NONE;
 SFS:(13230040)(1800799024)(376014)(366016)(38070700018); DIR:OUT; SFP:1102; 
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0: =?utf-8?B?dW8rTlN1SGlwMFVMRkRmVE12VTl2clpxUmRnVVRINm53YVkvWndaZHRHeGdn?=
 =?utf-8?B?SDhTckRjY2h0cU5DRWlCSnBZR04vNWxNU3VOTkZIS2swbEJwV0sya2QyMUNX?=
 =?utf-8?B?RGI3OHNHekdYQTE4dkQ1SThVKzNTTnlXK0JzekhHMXVTcm83b2VnOTM5UWhM?=
 =?utf-8?B?cFpaK1F4cXd1NmtldGtRWFV0Vmh4d2ZUNlFyWmYwdUhaKzZpc0NGSjV5MGZs?=
 =?utf-8?B?TjdHemY2QU9PTGZ4bk5meFg2MHJ0V0M2bm1DNS9uQzZWOTIvYTZhbmg1dnRn?=
 =?utf-8?B?eVcyUDBKTlhsMU4vaUlVL3ozR3JVUlNXM0g5NHZ3enBNYkIzemJhZkNSNHVw?=
 =?utf-8?B?VHJGeWZpMDc5MjVWL1huMWxwRTRRTm8xLzBzY3kxTTNMdTNaQ0tHQkFOZk1I?=
 =?utf-8?B?T1lBVGtpanhFaENCbnY1andJaFVFWXFOcnhqUHdhRGM4dWtHNlVVdEVNVnhv?=
 =?utf-8?B?QkpyZmcrTFJnOGUxZVE3cCs5aUtKOWdRTFJFS2wyZGIwZjlpMW1PRmlvYzNB?=
 =?utf-8?B?cDlzTWltMGFWM25vUEVoVUp4TFhPdG5DSEM3SGJWK0dnNVp4UFE5Umoyemt0?=
 =?utf-8?B?TG9HdU90Myt4QXcvM0tlYWxhQkRSV2JhN3I4UlFWclRwOUNubzFabllPRm1v?=
 =?utf-8?B?b3dQakkvVE1KTFJyS2ZvYlBKRUpOeGZYcytOL3NDZFRlOUpkWXVTck1BY3NS?=
 =?utf-8?B?QWJGUEFWVGE0NVRONGs0eS9maGc3YU81RGNiNFFVM2lrWm92NUx1d0ZkY05p?=
 =?utf-8?B?dnkvVDFGdyt0TExzUWFyY0dXV2pSU2hMYVpQbkh5ZkhUb0kvdW5URGVEWWxy?=
 =?utf-8?B?bXVRSzFHKzNyeXJqMjEzbHlzNStObnBlc0lyTmhNMnQzRGVodzRSZCthME5U?=
 =?utf-8?B?S1dHU21hWjNXcUV5eHN4aFpVajRCV09GUXdia2ZSZGd1dHlsY3lXZWpIQ2xF?=
 =?utf-8?B?WDJqclFiMGV2TGZ2bVc2Tk50V001dk5DdTFmYVlzSTlaTFVTNjlmaTlBbWtO?=
 =?utf-8?B?aEVjM3IyenU2T1haWU9lTEFSYjdVOGdJRnlpVWdMOEdvQzhaS3U0dklIQ21R?=
 =?utf-8?B?V3FPNTh5NHpyRjJVaFpoQmxPQjlkOXVoVE92aUNDS25PenVCTko2Z2xHeGNT?=
 =?utf-8?B?UmlXZnFtQVg1Z0tuOWRXT3J2SjN3YnNxMDVTR2pWKzBoNUZabEpXU0xsQjcz?=
 =?utf-8?B?dGtqZHhGRU1pT0RXOXhkSFJkUE9JTVVFQTMzUnViM0wzTForTmZQZGdQMHB4?=
 =?utf-8?B?bTAxK3pud3FsWFFCclN3RnRjanlaQ3NoWFFSaFhIR3dDL1hmRWxaRDJKOFpz?=
 =?utf-8?B?cUwxMFVHRERidGFmOXg2OElYSEt0anNoSFFIQkdQVjloZ3E4UUIxT2ZrSXh4?=
 =?utf-8?B?akZhN0FMeTNYdVhweUtaNUNEbkNzOUJqSjZsYy9RN1MvWEw5L0dLd3R0aUpy?=
 =?utf-8?B?WTUvTGszOW1XRW82bml1STUzTFZkV3hQWkxleHRudjNoN050VkJpMlVrMEE1?=
 =?utf-8?B?enpIMGltMzRpNVY3dVVCZUM2NWZ0RFo1M1ZQYUJsL3ZDdkE0V254Q0ZvRGxs?=
 =?utf-8?B?UG15L21OU2JIWlU4dTNQNFNnd2t4RWtxSlhLWjNJN3pLZ2EyT2MvUU4rS3B3?=
 =?utf-8?B?bGUrMFVSVDJNajY4RFJvUkR4SXhXY05aVGtQUUI2bTFvcXZJSkFiWW92NWVp?=
 =?utf-8?B?blVEbC9qaDhuZ0tGQVhXbjNmL0pwOGhHVFRCKzFxTG5EK2k4bUt3ZjV1OTVj?=
 =?utf-8?B?ZXFsRktKUGlCb3dmZDk4MjRBT0lxcms1cSsrSWt0b3IrVVBYTTRNdVhwYzVk?=
 =?utf-8?B?TmNuaUNIcmtrNXYvYVBsMm10eTV5WUVmNjhuS2gxRDJFWTlUNU9WWVBIOEpJ?=
 =?utf-8?B?YWpSN3o2Q3IraXJvRWNNQjI1ektzWGNBWWlPRDc3U3N6eW1TSWxlREMrTi9F?=
 =?utf-8?B?RVQwdE1KdDJlaEkrQkRINUZac1ZCMjJaOHgxRmxsVEt6TnpnMExiaWlRcXFI?=
 =?utf-8?B?cG5ZVHBZbW1qK0tQdUk2dUZHQ0Q1MHFJU1lETXhvN1dyZ1RXU041UU15WU81?=
 =?utf-8?B?MENjUFRkak5NdUtWUlZQd1c0QTBqWGR4UFdwanU4MHZOWFRjYWNuZWVlZ2JQ?=
 =?utf-8?Q?xfDlSFsZZCk7ydmeWukpx6gu6?=
Content-ID: <AF8D7979FD3768449403126C5768EE3C@teamddn.com>
MIME-Version: 1.0
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-0: kDld3OYGymPEBl8VtX04Yi4tQDr3MUHjtcLeFS7LcylWexJMjvdyK9kW/Jc339j85Zof6PqdbYRbs0aZhUchQQMPqxjubCviwZglJNVtXZUUFFMgqyDhpTE7RLNsNRvM8ReW/2DntlXTtwvfQh/qu/HCrV5cEmLbwqkOM8NhIafrVLanPQGh7o3lGzDr6zUj/aHBpnAcZMWn6bRBJf0o870m1N1AXkMy9m/r2mqYBVsqbQuQXw3ZxlO6aFxiAzJHUdisxl3u7r+/F+Hbtn6miYGzQOuwUyc43lGy9Tw/0EIxBGVf7vunJ9ZuqpPu/VhH7zlLpV/RW42g6Dx7oTL/O1yfOkM5WS6F6qcAEfvhyDykutpMMCalm1m3MHxigHmIjfR3Tj4i0fVa0/rqv5xMm6DBnKTZKwRP+2e1px2ky3s3114ZgvaQcP4vT4eNN45Ra6hB7Q2krA3qJ/ooJOaOysnND0SMiqrE3NkI014wgy1dSqmz+euq3X3GFXQYT85ouB2sgLTM8eUvyl4ilDZZTDK5ZECqa3sY7InjOt+oVH6Xw1KyoO/Pc7iE0djw+2FUl2yc05yxiYyt9ZtkyBz38saqSV0AESIWacOZyWcA6Ne861AXg1xbulOvVKGSmDK0ZfT0Qj27zxuVexgQQPiAZg==
X-OriginatorOrg: ddn.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: MW4PR19MB5630.namprd19.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 7aac4d51-979e-4470-7158-08dd454200d4
X-MS-Exchange-CrossTenant-originalarrivaltime: 04 Feb 2025 17:33:14.0500 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 753b6e26-6fd3-43e6-8248-3f1735d59bb4
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: 1XHvjcHu1JoxgTE0gCR7IT2dvVKzTT69kNg+agV+S2AMTk0BpTFrZRGlW9JPjZKl
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DS7PR19MB6229
X-BESS-ID: 1738690398-103716-7499-4023-1
X-BESS-VER: 2019.1_20250203.2302
X-BESS-Apparent-Source-IP: 104.47.58.48
X-BESS-Parts: H4sIAAAAAAACA4uuVkqtKFGyUioBkjpK+cVKVoaGxoZAVgZQMM3CzNQ4JcXY0D
 zVLMky1cwyzcI0zSQlxTw10dQs0SRJqTYWABOIkr5BAAAA
X-BESS-Outbound-Spam-Score: 0.10
X-BESS-Outbound-Spam-Report: Code version 3.2,
 rules version 3.2.2.262286 [from 
 cloudscan10-131.us-east-2a.ess.aws.cudaops.com]
 Rule breakdown below
 pts rule name              description
 ---- ---------------------- --------------------------------
 0.00 BSF_BESS_OUTBOUND      META: BESS Outbound 
 0.10 BSF_SC0_SA085          META: Custom Rule SA085 
X-BESS-Outbound-Spam-Status: SCORE=0.10 using account:ESS124931 scores of
 KILL_LEVEL=7.0 tests=BSF_BESS_OUTBOUND, BSF_SC0_SA085
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
Cc: "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

WW91IG92ZXJsb29rIHRoYXQgVGltIHdvcmtzIGZvciBBV1MsIHNvIGhlIHdvdWxkIG5vdCBhY3R1
YWxseSBwYXkgdG8gcnVuIHRoZXNlIG5vZGVzLiBIZSBjb3VsZCBydW4gaW4gbWFjaGluZSBpZGxl
IHRpbWVzIHdoaWxlIG5vIGV4dGVybmFsIGN1c3RvbWVyIGlzIHBheWluZyBmb3IgdGhlbS4gDQoN
Ckkgc3VzcGVjdCB3aXRoIHRoZSByYW5kb20gbmF0dXJlIG9mIHRoZSBib2lscG90IHRoYXQgaXQg
aXMgdGhlIHRvdGFsIG51bWJlciBvZiBob3VycyBydW50aW1lIHRoYXQgbWF0dGVyLCBub3Qgd2hl
dGhlciB0aGV5IGFyZSBjb250aWd1b3VzIG9yIG5vdC4gIFNvIHJ1bm5pbmcgMjR4IGJvaWxwb3Qg
bm9kZXMgZm9yIDFoIGR1cmluZyBvZmYtcGVhayB0aW1lcyB3b3VsZCBsaWtlbHkgcHJvZHVjZSB0
aGUgc2FtZSByZXN1bHQgYXMgMjRoIGNvbnRpbnVvdXMgb24gb25lIG5vZGUuIA0KDQpDaGVlcnMs
IEFuZHJlYXMNCg0KPiBPbiBGZWIgMywgMjAyNSwgYXQgMTU6MzAsIE9sZWcgRHJva2luIDxncmVl
bkB3aGFtY2xvdWQuY29tPiB3cm90ZToNCj4gDQo+IO+7v09uIE1vbiwgMjAyNS0wMi0wMyBhdCAy
MDoyNCArMDAwMCwgT2xlZyBEcm9raW4gd3JvdGU6DQo+IA0KPj4gYXQgJDExL2hvdXIgdGhlIG03
YS5tZXRhbC00OHhsIHdvdWxkIHRha2UgJDI2NCB0byBydW4gZm9yIGp1c3Qgb25lDQo+PiBkYXks
DQo+PiBhIHdlZWsgaXMgYW4gZXllLXdhdGVyaW5nICQxODQ4LCBzbyBydW5uaW5nIHRoaXMgZm9y
IGV2ZXJ5IHBhdGNoIGlzDQo+PiBub3QNCj4+IHN1cGVyIGVjb25vbWljYWwgSSdkIHNheS4NCj4g
DQo+IHgyZ2QgbWV0YWwgYXQgJDUuMzQgcGVyIGhvdXIgbWFrZXMgbW9yZSBzZW5zZSBhcyBpdCBo
YXMgbW9yZSBSQU0gKGFuZA0KPiA2NCBDUFVzIGlzIGFkZXF1YXRlIEknZCBzYXkpIGJ1dCBzdGls
bCBxdWl0ZSBwcmljZXkgaWYgeW91IHdhbnQgdG8gcnVuDQo+IHRoaXMgYXQgYW55IHNvcnQgb2Yg
c2NhbGUuDQo+IF9fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
DQo+IGx1c3RyZS1kZXZlbCBtYWlsaW5nIGxpc3QNCj4gbHVzdHJlLWRldmVsQGxpc3RzLmx1c3Ry
ZS5vcmcNCj4gaHR0cDovL2xpc3RzLmx1c3RyZS5vcmcvbGlzdGluZm8uY2dpL2x1c3RyZS1kZXZl
bC1sdXN0cmUub3JnDQpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fXwpsdXN0cmUtZGV2ZWwgbWFpbGluZyBsaXN0Cmx1c3RyZS1kZXZlbEBsaXN0cy5sdXN0cmUu
b3JnCmh0dHA6Ly9saXN0cy5sdXN0cmUub3JnL2xpc3RpbmZvLmNnaS9sdXN0cmUtZGV2ZWwtbHVz
dHJlLm9yZwo=
