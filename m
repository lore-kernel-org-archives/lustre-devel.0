Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 9E4E5C4332F
	for <lustre-devel@archiver.kernel.org>; Thu,  3 Nov 2022 17:53:43 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4N3BFL0lvQz1wR9;
	Thu,  3 Nov 2022 10:53:26 -0700 (PDT)
Received: from mta01.ornl.gov (mta01.ornl.gov [128.219.177.137])
 (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4N3BF96TTYz1wL9
 for <lustre-devel@lists.lustre.org>; Thu,  3 Nov 2022 10:53:17 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=ornl.gov; i=@ornl.gov; q=dns/txt; s=p20151116;
 t=1667497997; x=1699033997;
 h=from:to:subject:date:message-id:content-id:
 content-transfer-encoding:mime-version;
 bh=5boIAfIzC929l9Ger/f1VB+kvVCSugBXPTFwxBMc3sw=;
 b=s5To9zyDZrg55QQlWl0vat810KwMIL/honSVuxx8663r1feI1ppeF3A0
 6FhL7MQKEqMZoS+ESpEk1zdGWA5l92XS0JZPkdtxRrk6mYcQicEVy87wB
 53ThbbvbEhVbkAPk/NPrNm2Ea1HwknSTNXWdm62tuCA51QfCwDM4wywPS
 N4fTPxCFoP/AOR1ME1KORckgVJbn0iNfyWfY4XEKm+jvqMTQjuafg5BYj
 BAWLgY5DjzFpD93rnh80fL8yZRAeNShhay0TqZqavOp4my+TvACamwZEe
 PRA7QB3ete2DgSrwrUZKSb5wEprzVB7FWUQqnpgZj7PBVdC1j3mfChhJ5 g==;
X-SG: RELAYLIST
X-IronPort-AV: E=Sophos;i="5.96,134,1665460800"; d="scan'208";a="190298441"
Received: from emgwy1.ornl.gov ([160.91.254.9])
 by iron1.ornl.gov with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384;
 03 Nov 2022 13:53:15 -0400
Received: from exchhy01.ornl.gov (exchhy01.ornl.gov [128.219.12.157])
 (using TLSv1.2 with cipher ECDHE-RSA-AES256-SHA384 (256/256 bits))
 (No client certificate requested)
 by emgwy1.ornl.gov (Postfix) with ESMTPS id 4N3BF722Q7z2VVvc;
 Thu,  3 Nov 2022 13:53:15 -0400 (EDT)
Received: from exchhy04.ornl.gov (128.219.12.143) by exchhy01.ornl.gov
 (128.219.12.157) with Microsoft SMTP Server (TLS) id 15.0.1497.42; Thu, 3 Nov
 2022 13:53:14 -0400
Received: from exchhy01.ornl.gov (128.219.12.157) by exchhy04.ornl.gov
 (128.219.12.143) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.2.986.30; Thu, 3 Nov 2022
 13:53:14 -0400
Received: from GCC02-BL0-obe.outbound.protection.outlook.com (160.91.94.6) by
 exchhy01.ornl.gov (128.219.12.157) with Microsoft SMTP Server (TLS)
 id
 15.0.1497.42 via Frontend Transport; Thu, 3 Nov 2022 13:53:14 -0400
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=CewbHnn2kQ32TDZJ7F/o2YzP6ICgb3IWNSCNWt+BHoRXHhk3QzA8INkDBGrWk/wlhKmI8A+Q7o403XDsBsb6G2Pg0g7GUwCkamAz0cs8KNnti5wr9Zx58wyt6HIzpimepu8aJ2z0yMXVrfXq0KUAqK5G4eZhVPOL/iaUVAtf2J57GXBGlW9es8tULHZLpppcktRsFWCI80Ldm3f8wZbF4uuDkLaLXN2Y/4Cv5SWbSXNG05waXhpgyaHeV8t9pc+0M5qPYR7vrlC8Ip0xnvxO/WTHzyzgH5V749ZT8Zq4b62dcYpWe3vCj+Q8wFqgvaY5UvBcOQtpWocHLbHhOtsBdA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com; 
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=5boIAfIzC929l9Ger/f1VB+kvVCSugBXPTFwxBMc3sw=;
 b=edkBdyQUq7DGNI7891R2P/SPxCnRXZnhlOJqfXNIJys3aBvwl0UyTtsI9y0Gzd3jMakAH1gJzwMqp5uDM+mRx25YOnon0eqZevH0OyzmAd4HfyZL+cm+rZ1ZgKTkt3l0SLeQC8GG86B8WP2zthJcfIDt4CLOV8oSNAOHSPWXNczMGV0gNmfrqVofnyJPmQlL4DhaL6/xoT8tkw2dnOoVj7R0qXmuzX0FEahY/PmUthw0C15B7HAJvNCx8KYckAUtaIIj+0AbY5FaFUjmJMDoPQYmBJY1sqzTtkEgmBhRffxVlciznnFuROCmHyH7Ajg4uDE2QQfUj99doQrdTRiIlA==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=ornl.gov; dmarc=pass action=none header.from=ornl.gov;
 dkim=pass header.d=ornl.gov; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ornl.gov; s=selector2; 
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=5boIAfIzC929l9Ger/f1VB+kvVCSugBXPTFwxBMc3sw=;
 b=LvP61eFgtbY9Xa4TF0pLALM71UROKExd3ePDfxYwqF/lLTAghO/E+OrXAv0ZtW4aPdO80G076oFCFKqeNJpmu5wFsg90zPzc2d46z4XNvxs09WWuTkd1TQf0h0ndtuCD/oOTDNMQeXxd2Fo6jvtM6ozNIr0hZ+fwbfp+mkFeU7g=
Received: from SA1PR09MB8907.namprd09.prod.outlook.com (2603:10b6:806:28d::9)
 by DM6PR09MB5461.namprd09.prod.outlook.com (2603:10b6:5:269::19) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.5791.22; Thu, 3 Nov
 2022 17:53:13 +0000
Received: from SA1PR09MB8907.namprd09.prod.outlook.com
 ([fe80::380:3aec:5ef5:a4b6]) by SA1PR09MB8907.namprd09.prod.outlook.com
 ([fe80::380:3aec:5ef5:a4b6%3]) with mapi id 15.20.5769.021; Thu, 3 Nov 2022
 17:53:13 +0000
To: "Yitschak, Yehuda" <yehuday@amazon.com>, "lustre-devel@lists.lustre.org"
 <lustre-devel@lists.lustre.org>
Thread-Topic: [EXTERNAL] [lustre-devel] lnet selftest using large NIDs (16
 byte)
Thread-Index: AQHY760kFmOA26QwVUmS7svD4mRuGw==
Date: Thu, 3 Nov 2022 17:53:13 +0000
Message-ID: <AC1D1063-35BB-4DF3-ABEF-753419BB941A@ornl.gov>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
user-agent: Microsoft-MacOutlook/16.66.22101101
authentication-results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=ornl.gov;
x-ms-publictraffictype: Email
x-ms-traffictypediagnostic: SA1PR09MB8907:EE_|DM6PR09MB5461:EE_
x-ms-office365-filtering-correlation-id: 921e8bb4-64ca-428f-627f-08dabdc4477a
x-ld-processed: db3dbd43-4c4b-4544-9f8a-0553f9f5f25e,ExtAddr
x-ms-exchange-senderadcheck: 1
x-ms-exchange-antispam-relay: 0
x-microsoft-antispam: BCL:0;
x-microsoft-antispam-message-info: XwX8wg6HC1lfJF7cJzMqR39NW32CEhEJPq3e254I+4okGHGd0a046V8M4Kaeya00mR/OnhpPXoV2x2vVpSzUaeTz+V9/HojOPH2w7KMBLTekbu7RqYyNULUpB2F2alqLNDp8Ss0uDSqIJiNMxcOPFgdIHU9w8PRoMvY93XiCqRexnW19kedJzW9Y+4xuHRapB/iM5ZBHixKf2JW+qShb1yhXArtQHWf7TurLnKx9oW7M+w/NHJkxG2WBQf5Oo1vUkmgqNRUtcruXNDvpeYRIKys7tAquaWrDclDlJ+nNwyeZba4iRg8bocay0Ik0oG59Dkt8t5RMVXT4kwAIAWHj3qJweyJ92viPciiRfLtR2xPEEIMb9LrqTpabFDiNqUaoGXQ51kfWjp4qKY5JGqyWSyLVb/uuthBXsEW9SRqq0HUS/WIy7Xbsmaq62S7DfP+kP3cJeJ5OmBjkeCiPI6Tvre8h2M5e9MSTmcasCrnRP/n6R+VmOR6ecYxRPR/3MN012DqI1WQIkbEkGcXrB/uj9WzAegx2plNqIDipiYNjtE32R7dR7cp/YCM+VreDK43PbiOlpqHG1d0u103R52d1N10Do+3NMRqiJv0u/kj6l6+AYzuJRh96mag7j7irRnGlRgiwEAWM6JwEODGfj6DL6JWZxHcxIYYd/q4kXC/41+MxSonUJuPJvJXOPrSzaIE5v52pcJRg0jX0VnTZz1jWYgdU9xvLWYwewGnROm/X8ZWMoWa3Rc9JHmZ59oteGDSPSUW8dGYEVpw06x/d6bT8wBAvcJv6J7LIKR6CbkuHYU/zONoVt90RDwzaKUbS4S5EZjWF+FdJ2dRCLvjiqpmFaA==
x-forefront-antispam-report: CIP:255.255.255.255; CTRY:; LANG:en; SCL:1; SRV:;
 IPV:NLI; SFV:NSPM; H:SA1PR09MB8907.namprd09.prod.outlook.com; PTR:; CAT:NONE;
 SFS:(13230022)(4636009)(366004)(451199015)(498600001)(2616005)(6512007)(5660300002)(186003)(6486002)(8936002)(83380400001)(91956017)(66476007)(66556008)(71200400001)(66446008)(64756008)(8676002)(2906002)(36756003)(66946007)(122000001)(38100700002)(82960400001)(6506007)(33656002)(76116006)(38070700005)(110136005)(86362001)(13693001)(45980500001);
 DIR:OUT; SFP:1102; 
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0: =?utf-8?B?V1pVMmpFWGpsSC9KbXBuS2FKa0lWVW8xRDkvcTJWQTYvWndndDBHTTk2aVcy?=
 =?utf-8?B?M2FDc0t2dzZMTUJyTmtON2NCSzlBbTRaZWk4T1BDT1pBc2MyOGhSdzZ6SHhw?=
 =?utf-8?B?SDNVeHFPMHMrcUQ3MUJQbkdqd3FjWi80OHZ3ajNyaVAwWktWMU01Q3lPUkxu?=
 =?utf-8?B?Ri85MXB0dmtvZXYrN3Q0WExZSUxoV2c2a05WTExSYXg2VDJwVTNZS1M0V3Ju?=
 =?utf-8?B?eE9JL3k1eUJiTWhEck5ndDlUK0p0Wm9UMnpMdUtTZGpWMHdZM1RBWUlLVTdo?=
 =?utf-8?B?S1RnbmlBamJFdGVKUWRkQkE0VjNxN2NxczRSK1hFb3FpUlR0NWIzMEQ5QzVz?=
 =?utf-8?B?bm5xVkFidTZvYThIemhUUXJnWE9PbGRscFFWcjRhWlRVMFpVbTg3MTVMNmJJ?=
 =?utf-8?B?Mk5QMnJiak92dFMxUXpGSTc3ay90SjgvaFJzQ1dUV1M2MFlmMVFINFJ5RjV0?=
 =?utf-8?B?QWE2MlNpMmRLL3RqMzZnTUY3OG1yOFFjRWRxN292bEZLaUNEOEk5TGhRd2lW?=
 =?utf-8?B?QVF3MGVlRVhoMjYvbTlWbWpQYTBRdlMzZ1FUZFc4TzMzNmhnbHczN2ZQMVo0?=
 =?utf-8?B?UHl1MWlXNS84ZmpZNXRTa2xaem5tekRYOVJuL3YvK3lTb3l2dFBEdXF4NEll?=
 =?utf-8?B?cm9EcFgrWjN0UW9WQnFVV3RSNkR0UDZqa1U2aW5jdHRpeWdLd1RUcUV0bGtZ?=
 =?utf-8?B?bGtsYWhUdnR3TGIrcGVZTnpBUFB5ZFYzcWxOb0hGS2l3VDhJNjBVMW0rdWdG?=
 =?utf-8?B?SjNFditUTE8zaFRFM3FwdnpYK0pleE9icm9lTW9QQjRxK28vakt6RjBPL0ZC?=
 =?utf-8?B?OUkrRlMxVDlTd0xFTUpyMzhKQWpadTBxV2RqTXFTN3VpMUJKcFFNRWlKY25k?=
 =?utf-8?B?ODMzRHVUdzBVYWJBRnJnWVFhSjc2RkFNM3cvcy9YOUVWMHg1VmJlK2c0dHZC?=
 =?utf-8?B?ODVjVUNWV3NyTmtuSnFsdDZZU0dNbi84ZkhKVGVZZmFqQlptMFdUOHB0QXU3?=
 =?utf-8?B?Z0d0M0FScjFqUG4xaHQxSFI4OGZISDdXUFUvV2dlWG1yN0lwd0hKZlZmelZE?=
 =?utf-8?B?ZnZWd0xnSERkeHhDN05TbmtBVERqNkFKRmxNR1hrSGt3ZmIydklFZjZ5Z0lX?=
 =?utf-8?B?RFA0TkxwSC8vWitGamdZa3VtcUlQUnpIUzM1SnI1bzA3Sjl6MWNaTytUMkgr?=
 =?utf-8?B?bjFkM0RpMUhMRWlLVEk4NitlSG5CaURTb0Qza3hyeTkxVUxnMWJ1eWk3SG5X?=
 =?utf-8?B?UGZyUnRVemI5UW5nTkU3b3lHUFVWMEc4MHRldGc2K0Y1cWJtZVkyOW8wSTFB?=
 =?utf-8?B?VW56YlNnNHVQNVd5L2cyNkwwYTdhZmR6N29xSGZ1NWVoVWp3Vm5QbUxNRVgr?=
 =?utf-8?B?Z2VmbEJyWXBxZk1YQXlGSFJYTVF1R2xVWjVKYnBCUTRrNXF3dVpqT25wa2pt?=
 =?utf-8?B?cHFkaytkZEs3MGpZTmNyallTQjhvT1o0Wmh0VGMwVGdlbm02QmJzejFjaDBF?=
 =?utf-8?B?dmlILzlGMXNjS29rUXM3TWREMjhuZWNjeit2c09nM2g1ZW16bzVqRDlDOFRR?=
 =?utf-8?B?RGtoZzBlbC81cW51Q0lFUzlnWGRnRk5GNXk0VEpWTFZjM3JLR1paNkVROEhM?=
 =?utf-8?B?ZXpvMmhSWG9NYS9ja3dObXlHcVVDbC9hNVgvejhZZmh2R3VzK1VHM2RRVFIx?=
 =?utf-8?B?Q1FCZm5QUnI5SjBmREE0QlNmNzdUaGs4STd0MVhLSGU4Y3hKUVBoeER4RGYr?=
 =?utf-8?B?aUMwRlpoSkxCTVNuK0hmRC9MeURSS3E0dDZyeitaQ1NJbitIaTYxUEVBeFVR?=
 =?utf-8?B?Si9ldjZYb1NXWHlWdjRCcExQOUdEM1FYSkFWV0tEZTllbUVraEJHSkt3TGdw?=
 =?utf-8?B?aGROQnEwU1l6OThBL1dqMmhpZDRiTk83T3JPdUtmNjlpaGRxVWdEZFNkZ0Vx?=
 =?utf-8?B?dWpGREgwWk5GZXViZ3FZYzVXZ0FCUlQ2MjBBcSt6Y0VHZXpCTUMydHd4MkNK?=
 =?utf-8?B?L1ZTR2s4RnBiK3lhVXV3bGdQODQ5bmcySVRiQW51VVV0QTdRMUJPWGI4Y2Ry?=
 =?utf-8?B?TGtUMjh0TzFnMy92RzNoUTA2R1BEdXBWZE1VbkZsakFQWXIxTEZ0ODJwcjJC?=
 =?utf-8?Q?S3DoGWWo7PIcIqblTRCTPsRCy?=
Content-ID: <D9A69EBD9C08E149AA2DCD6E97A13125@namprd09.prod.outlook.com>
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: SA1PR09MB8907.namprd09.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 921e8bb4-64ca-428f-627f-08dabdc4477a
X-MS-Exchange-CrossTenant-originalarrivaltime: 03 Nov 2022 17:53:13.6632 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: db3dbd43-4c4b-4544-9f8a-0553f9f5f25e
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DM6PR09MB5461
X-OriginatorOrg: ornl.gov
Subject: Re: [lustre-devel] [EXTERNAL] lnet selftest using large NIDs (16
 byte)
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
From: "Simmons, James via lustre-devel" <lustre-devel@lists.lustre.org>
Reply-To: "Simmons, James" <simmonsja@ornl.gov>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

DQogICA+ID4+SGVsbG8gDQogICA+Pj4NCiAgID4+PkkgYW0gd29ya2luZyBvbiBhIFBvQyBmb3Ig
YSBuZXcgTE5EIHdoaWNoIG5lZWQgdG8gdXNlIGEgMTYgYnl0ZXMgTklEIGFkZHJlc3MNCiAgID4+
PkkgYW0gY3VycmVudGx5IGZhY2luZyBpc3N1ZXMgYWRkaW5nIGEgMTZieXRlIE5JRCB0byBMbmV0
IHNlbGZ0ZXN0IHNpbmNlIGl0IG9ubHkgaGFuZGxlcyA0IGJ5dGUgTklEcw0KICAgPj4+DQogICA+
Pj5BcmUgdGhlcmUgYW55IHBhdGNoZXMgb3IgV0lQIHRvIGFkZCAxNiBieXRlIE5JRCBzdXBwb3J0
IHRvIExTVCA/IA0KICAgPj5ZZXMsIHRoZXJlIGlzIGJ1dCBpdOKAmXMgdW5kZXIgY3VycmVudCBk
ZXZlbG9wbWVudC4gVG8gdHJ5IGl0IG91dCB5b3UgbmVlZCB0aGUgbGF0ZXN0IEx1c3RyZSBjb2Rl
IHBsdXMgYSBidW5jaCBvZiBwYXRjaGVzLg0KICAgPj5Zb3UgY2FuIHNlZSB3aGVyZSB3ZSBhcmUg
YXQgdGhpcyBsaW5rIGh4eHBzOi8vamlyYS53aGFtY2xvdWQuY29tL2Jyb3dzZS9MVS0xMDM5MS4N
CiAgID4+DQogICA+PlNpbmNlIGdvaW5nIHRocm91Z2ggdGhlIHRpY2tldHMgaXMgZ29pbmcgdG8g
YmUgYSBsb3QsIEkgY2FuIGdpdmUgeW91IGEgcXVpY2sgc3VtbWFyeS4gVGhlIGJhc2ljIGluZnJh
c3RydWN0dXJlIGlzIGluIHRoZQ0KICAgPj5jb3JlIExOZXQgY29kZSBidXQgdGhlIGJpZyBjaGFu
Z2VzIG5lZWRlZCBhcmUgdGhlIHdpcmUgcHJvdG9jb2wgaGVhZGVycyBhbmQgdXNlciBsYW5kIGlu
dGVyZmFjZSB0b29scy4gTm90ZSBoYXZpbmcNCiAgID4+THVzdHJlIHVzaW5nIGxhcmdlIE5JRFMg
aXMgYW5vdGhlciBzZXQgb2YgdGlja2V0cyB3aGljaCBhcmUgbm90IHRoZXJlIHlldC4NCiAgID4N
CiAgID5TdGlsbCBsZWFybmluZyBteSB3YXkgdGhyb3VnaCBMdXN0cmUg8J+Yii4gDQogICA+eW91
IG1lYW4gYWxsIHRoZSByZXF1aXJlZCB3b3JrIGlzIGNvdmVyZWQgYnkgV0lQIHBhdGNoZXMgb3Ig
c29tZSBzdHVmZiBhcmUgc3RpbGwgbm90IGNvZGVkID8NCg0KICAgWWVzIGFuZCB5ZXMuIFdlIGhh
dmUgb3V0c3RhbmRpbmcgcGF0Y2hlcyB0aGF0IGFyZSBuZWFyaW5nIGxhbmRpbmcgYW5kIHRoZXJl
IGlzIG1vcmUgd29yayB0byBiZSBkb25lIHRoYXQNCiAgIGhhc24ndCBiZWVuIHdyaXR0ZW4uDQoN
CiAgID4+IEl0IGRvZXNu4oCZdCBzb3VuZCBsaWtlIHlvdSBhcmUgbG9va2luZyBmb3IgYSBmdW5j
dGlvbmFsIGZpbGUgc3lzdGVtIG9uIHRvcCBvZiB5b3VyIGludGVyY29ubmVjdCBhdCB0aGlzIHBv
aW50Lg0KICAgPg0KICAgPnlvdSBhcmUgcmlnaHQuIEkgYW0gbW9zdGx5IHRyeWluZyB0byBzZWUg
dGhlIEJXIHBvdGVudGlhbCB1c2luZyBMbmV0IHNlbGZ0ZXN0Lg0KICAgPkkgYW0gY3VycmVudGx5
IGhhY2tpbmcgdGhlIGFsbCBhZGRyZXNzaW5nIHRoaW5nIGJ1dCBsb25nIHRlcm0gd2lsbCBwcm9i
YWJseSBuZWVkIHRoZSBsYXJnZSBOSUQgc29sdXRpb24uDQoNCiAgIEl0cyBtb3JlIGNvbXBsaWNh
dGVkIHRoYW4geW91IHRoaW5rLiBBIGxvdCBvZiB3b3JrIHdlbnQgaW50byBMdXN0cmUgMi4xMyBh
bmQgMi4xNCB0byBnZXQgdG8gdGhlIHN0YWdlIHdlIGFyZSBhdC4NCiAgIEZvciB5b3VyIHNhbml0
eSBJIHJlY29tbWVuZCB0aGF0IHlvdSBtb3ZlIHRvIG91ciB3b3JrLg0KDQogICAgPkF0IHRoaXMg
cG9pbnQgdGhlIGdvYWwgd2lsbCBiZSB0byBnZXQgbG5ldCBzZWxmdGVzdCB0byBkbyBwaW5nIHRl
c3Qgb3ZlciB0aGUgd2lyZSBiZXR3ZWVuIHR3byBsYXJnZSBOSUQuIElmDQogICAgPnlvdSBhcmUg
aW50ZXJlc3RlZCBpbiB0aGlzIHdvcmsgbGV0IG1lIGtub3cuIEl0IHdvdWxkIGJlIGdyZWF0IGlm
IHlvdSBjYW4gYmUgYW4gZWFybHkgdGVzdGVyLiBJdCB3b3VsZCBiZQ0KICAgID5uaWNlIHRvIGdl
dCBmZWVkYmFjayBvbiB0aGlzIHdvcmsuDQogICAgLi4uLg0KICAgID5JIHdvdWxkIGJlIGdsYWQg
dG8gdHJ5IGl0LiBJdCBtaWdodCB0YWtlIG1lIGEgd2hpbGUgYmVjYXVzZSBJJ20gY3VycmVudGx5
IGJhc2VkIG9uIDIuMTIgYW5kIHJlYmFzaW5nIG1pZ2h0IGJlIGEgcGFpbi4NCiAgICA+QnV0IEkn
bGwgZGVmaW5pdGVseSBtYWtlIHNvbWUgdGltZSBmb3IgdGhhdCBhcyBzb29uIGFzIG15IExORCBj
b2RlIHN0YWJpbGl6ZXMuICANCg0KICAgIFRoZXJlIGlzIG5vIHN1cHBvcnQgZm9yIHRoaXMgd29y
ayBpbiAyLjEyLiBZb3UgYXJlIGdvaW5nIHRvIGhhdmUgdG8gbW92ZSB0byBhIG5ld2VyIGx1c3Ry
ZSB2ZXJzaW9uLiBMTkQgZm9yd2FyZA0KICAgIHBvcnRpbmcgc2hvdWxkbid0IGJlIHRvIHBhaW5m
dWwuIFRoZSBiaWdnZXN0IGNoYW5nZSBpcyB0aGUgTE5ldCBoZWFsdGggd29yayBidXQgaXQncyBu
b3QgYSBoYXJkIHJlcXVpcmVtZW50Lg0KICAgIFdoYXQgd2lsbCBuZWVkIHRvIGJlIGNoYW5nZWQg
aXMgc3VwcG9ydCBmb3IgdGhlIGxhcmdlIG5pZCBzdXBwb3J0LiBCeSB0aGF0IEkgbWVhbiBtb3Zp
bmcgZnJvbQ0KDQogICBsbmV0X25pZF90ICAtPiBzdHJ1Y3QgbG5ldF9uaWQNCg0KICAgVGhlIHBv
cnQgd2lsbCBiZSBlYXNpZXIgdGhhbiB5b3UgdGhpbmsuDQoNCiAgICA+V2UgaGF2ZSBhIHNsYWNr
IGNoYW5uZWwgd2hlcmUgd2UgaGF2ZSBkaXNjdXNzaW9ucyBvbiB0aGUgcHJvZ3Jlc3MNCiAgICA+
b2YgdGhpcyB3b3JrLiBZb3Ugd2lsbCBoYXZlIHF1ZXN0aW9ucyBhYm91dCB0aGUgY2hhbmdlcyBu
ZWVkZWQgdG8gcHJvcGVybHkgc3VwcG9ydCB5b3VyIExORCBkcml2ZXIgdGhlIA0KICAgID5zbGFj
ayBjaGFubmVsIGlzIHRoZSBiZXN0IHBsYWNlIHRvIGFzayB0aG9zZS4gRmVlbCBmcmVlIHRvIGFz
ayBoZXJlIGFzIHdlbGwgaWYgeW91IHByZWZlci4gU29tZW9uZSB3aWxsIA0KICAgID5hbnN3ZXIu
IExldCBtZSBrbm93IGlmIHlvdSB3YW50IHRvIGpvaW4gdGhlIHNsYWNrIGNoYW5uZWwuDQoNCiAg
ICBTdXJlLCBJJ2xsIGJlIGhhcHB5IHRvIGpvaW4geW91ciBzbGFjayBjaGFubmVsLg0KICAgIFRo
YW5rcyBmb3IgdGhlIGFsbCBpbmZvIGFuZCB0aGUgc2xhY2sgaW52aXRlICEgDQoNCiAgICBZZWh1
ZGEgDQoNCl9fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fCmx1
c3RyZS1kZXZlbCBtYWlsaW5nIGxpc3QKbHVzdHJlLWRldmVsQGxpc3RzLmx1c3RyZS5vcmcKaHR0
cDovL2xpc3RzLmx1c3RyZS5vcmcvbGlzdGluZm8uY2dpL2x1c3RyZS1kZXZlbC1sdXN0cmUub3Jn
Cg==
