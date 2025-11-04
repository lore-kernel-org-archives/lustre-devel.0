Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 339A4CCF9E3
	for <lustre-devel@archiver.kernel.org>; Tue,  4 Nov 2025 21:22:46 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4d1Lkc2y0qz23XK;
	Tue, 04 Nov 2025 13:12:24 -0800 (PST)
Received: from iad-out-009.esa.us-east-1.outbound.mail-perimeter.amazon.com
 (iad-out-009.esa.us-east-1.outbound.mail-perimeter.amazon.com
 [34.198.94.229])
 (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4d1LkQ3Zdgz23Wc
 for <lustre-devel@lists.lustre.org>; Tue, 04 Nov 2025 13:12:14 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=amazon.com; i=@amazon.com; q=dns/txt; s=amazoncorp2;
 t=1762290734; x=1793826734;
 h=from:to:cc:date:message-id:references:in-reply-to:
 content-id:content-transfer-encoding:mime-version:subject;
 bh=BgBH4N9JbumFnc7kcfxUK6EI/YoxjUZF8c7wdEAwhxw=;
 b=kZls/NUjlZpZLRf1SIsSNq1fkZ9pAT9Ky88VdthtECU2ePqihflwp4Y6
 UImDJiU70y3mw+svp2N35F7/IV66pzPc6xwu/FUvWOa2PHDc6lO3eYOHa
 ayrpWQ5Mk2CxbcCZ27Zt7SSTsKLZDPUe0igJ6TOhssz8WGxk715TZBAQC
 h7Bhc4KN4yQvml9qnzdx4ph3vaXfpAy1QalCYdQGqOt4aMtnAmg6QEmTN
 alPnmpH51d89R+oxQomsna1zQcuz40eoCTdhm6AQ5+OHN4CcFLlWCNiPY
 LnQkD7yCu3pEeSCsTjqrEAFu5KmkBa72Cg37184vJ+xqjDiS3tfGVWFUl w==;
X-CSE-ConnectionGUID: kL/PYXmYRRKkU4e7KXryNA==
X-CSE-MsgGUID: F0282Ch7QxqkN8Uzp6XlQg==
X-IronPort-AV: E=Sophos;i="6.19,280,1754956800"; 
   d="scan'208";a="5638228"
Thread-Topic: RFC: Spill device for Lustre OSD
Received: from ip-10-4-10-75.ec2.internal (HELO
 smtpout.naws.us-east-1.prod.farcaster.email.amazon.dev) ([10.4.10.75])
 by internal-iad-out-009.esa.us-east-1.outbound.mail-perimeter.amazon.com with
 ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 04 Nov 2025 21:11:46 +0000
Received: from EX19MTAUEC001.ant.amazon.com [52.94.133.142:26779]
 by smtpin.naws.us-east-1.prod.farcaster.email.amazon.dev [10.0.1.157:2525]
 with esmtp (Farcaster)
 id b981395b-89c6-4604-a372-fa2388590117; Tue, 4 Nov 2025 21:11:45 +0000 (UTC)
X-Farcaster-Flow-ID: b981395b-89c6-4604-a372-fa2388590117
Received: from EX19EXOUEC002.ant.amazon.com (10.252.135.179) by
 EX19MTAUEC001.ant.amazon.com (10.252.135.222) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA) id 15.2.2562.29;
 Tue, 4 Nov 2025 21:11:45 +0000
Received: from CH4PR07CU001.outbound.protection.outlook.com (10.252.134.239)
 by EX19EXOUEC002.ant.amazon.com (10.252.135.179) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA) id 15.2.2562.29
 via Frontend Transport; Tue, 4 Nov 2025 21:11:45 +0000
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=AKwI1PW5JfBa8Lw75cQoUIHi3RjIl2hfahzqTtaEmUKlKg3pKfWyY5Vt+9GeDTQCBK6gE0V/Njt+ZL5yuWEV2ffgNZG8y7noRqMeqgZRgDuSXfF2ibQ4QjHSS5AoMt/L4zrwL5MY5nW5P6WkWQD+M62lcbkMVgzTyMQO1XIFFJAThUuiZ7zFyGl3tLYx8NiYdmXDT5hVo9gc1yEyn3KNS6tuuWBnMeg5S+2GCTmnefsVnRX+gaFvXdMDwUqFLiTHtUcO33GaoBwvlatDh9l+Nzx6gj5CaNZDbb83Z8DgC3rJsqAXm6xJYZGeBBQypi3r4mrXv8dO1UOSdNr6Cp+4WA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com; 
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=BgBH4N9JbumFnc7kcfxUK6EI/YoxjUZF8c7wdEAwhxw=;
 b=ae20ZmC8OaXV9AhkE6vdvxBjXVl/9FEO/lsFwXUtoZ/BZ/I5rqYwWgOc/ZsMAvC/N3OBN30NZQowu4kUdZErOqdhcmwbNYX9yHAc2LGzPuVeFrRsjWzBBv7GC/a/76sMg5hHu0biX+OE25GXpnKeavCZ2xksu5bPqtgFBp6Ato6YuQVsW/ifZgJsjHaa9fDA74D3kf1NmLdj7IjRDb9qJuctM6odpl5YozBrE7jGvUKRFL5tl2KqWQqxAtpFJeZ0RLFpglbxoyLeiF8JTWXhy8dGZviVwuks+lrT6DnYa69f03Aw41IA875OOd3SSHYG0R+WybCohQKR8wB856el7Q==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=amazon.com; dmarc=pass action=none header.from=amazon.com;
 dkim=pass header.d=amazon.com; arc=none
Received: from DM6PR18MB3667.namprd18.prod.outlook.com (2603:10b6:5:2ae::22)
 by CH3PR18MB6119.namprd18.prod.outlook.com (2603:10b6:610:1e1::12) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.9275.16; Tue, 4 Nov
 2025 21:11:42 +0000
Received: from DM6PR18MB3667.namprd18.prod.outlook.com
 ([fe80::2aeb:6b41:4331:4be1]) by DM6PR18MB3667.namprd18.prod.outlook.com
 ([fe80::2aeb:6b41:4331:4be1%4]) with mapi id 15.20.9275.015; Tue, 4 Nov 2025
 21:11:40 +0000
To: Jinshan Xiong <jinshan.xiong@gmail.com>
Thread-Index: AQHcTE/AGdVndrjiSE2WWCbdtaJ3z7ThLbQAgAB1AQCAARASgA==
Date: Tue, 4 Nov 2025 21:11:39 +0000
Message-ID: <D8E0F0C0-1A5F-413A-82EA-F3CFA473D2E1@amazon.com>
References: <CFE3C4C8-104E-4F7F-A52E-21B8957FAC0F@amazon.com>
 <0092A54A-6EEF-4CD3-8AFD-7B0066A08810@gmail.com>
In-Reply-To: <0092A54A-6EEF-4CD3-8AFD-7B0066A08810@gmail.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
msip_labels: MSIP_Label_19e68092-05df-4271-8e3e-b2a4c82ba797_Enabled=true;
 MSIP_Label_19e68092-05df-4271-8e3e-b2a4c82ba797_SetDate=2025-11-04T20:32:46Z;
 MSIP_Label_19e68092-05df-4271-8e3e-b2a4c82ba797_ContentBits=0;
 MSIP_Label_19e68092-05df-4271-8e3e-b2a4c82ba797_Enabled=true;
 MSIP_Label_19e68092-05df-4271-8e3e-b2a4c82ba797_Tag=50, 3, 0,
 1; MSIP_Label_19e68092-05df-4271-8e3e-b2a4c82ba797_Name=Confidential;
 MSIP_Label_19e68092-05df-4271-8e3e-b2a4c82ba797_ActionId=af4540a4-4696-48af-b09a-386c7b00a74f;
 MSIP_Label_19e68092-05df-4271-8e3e-b2a4c82ba797_SiteId=5280104a-472d-4538-9ccf-1e1d0efe8b1b;
 MSIP_Label_19e68092-05df-4271-8e3e-b2a4c82ba797_Method=Standard; 
authentication-results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=amazon.com;
x-ms-publictraffictype: Email
x-ms-traffictypediagnostic: DM6PR18MB3667:EE_|CH3PR18MB6119:EE_
x-ms-office365-filtering-correlation-id: c41b930b-2188-42ae-08e7-08de1be6bf54
x-ms-exchange-senderadcheck: 1
x-ms-exchange-antispam-relay: 0
x-microsoft-antispam: BCL:0; ARA:13230040|376014|366016|1800799024|38070700021;
x-microsoft-antispam-message-info: =?utf-8?B?aUtzdDl3eXhDb1dPdEtla1cyNlVBbGduU1Y3TWw4TnJsZmUzV1RTcjJWQlpN?=
 =?utf-8?B?Tnc0MlBib2hxWWdobnhEbzNxbEYzTUxqY0xmZEJCTUJGNG9lSm0vTWdsZGVR?=
 =?utf-8?B?NVh1ZVRhMTVDbUlPYUkrb0hkMXFLclZNbDBMK2U1Y1VpNXVuSFdHUHNuUHlv?=
 =?utf-8?B?b0k0NkVIY0pVWmZNWnVLREcvcWVramhKdm95NnhNbGRpRFhxYnlrQkd0ZFBI?=
 =?utf-8?B?UFJ2elFJS2d1ell2NzA4bzVjU1BZMFlwTGd1RC9OOS9zTXlMWGgyT1NMeGVF?=
 =?utf-8?B?OVVlUWROaTBFZnZxK1dMUmtqREhtSk9TZnAzZVpDYjJYQVUwNmFCM0M4bml0?=
 =?utf-8?B?WHRmVUw4eXkzenUwczEvaGw1QWxvRzFWMWQxd0JxS0VxS2wzWDZrQU4xN0RQ?=
 =?utf-8?B?eWM1eFYvc24zZWp2TXJlbTlSQjRzWmZyQUhpSlZFM0lVSjhvMWdDTllidGVT?=
 =?utf-8?B?cXF5K1gxVSt2K3ZqczU0OGVhWVZxem9LV1g5ZWhVZUZCanR1YkpQWXRHSUpO?=
 =?utf-8?B?SDVzeFEvczVoaW5nYlE1dzkxY080eVBXS0kzamVXY3UwNm1IVVFML216WEZs?=
 =?utf-8?B?ZXFCZVpkZ2o0eVBRWGNpUURIV0lQL0N2QkkzMm0yUFJLd1BiRG50R1JPek1E?=
 =?utf-8?B?R0VYUWJ4cEVKZEowbVN4NlY1N21DQ2hkQjFTVGFjN0JuL0FudGtsUmY0aWhs?=
 =?utf-8?B?a1dOSkpEWVFKZG85MkE2MU9HUTZ2Z1czV2dqbHhrR09hYnA1L0JUcDJmUWdj?=
 =?utf-8?B?Ym1iY3FaS3RTOGZXc2haMXgrOUc2Z1ZNWEo5RzNFNytxUTdLY3QrK3lNNGFa?=
 =?utf-8?B?OHNEdFJNK08ybWFqRlBPUXNRNFdjK051bFAzQ2NxeDdOcnVsQjk0NGxPcEVW?=
 =?utf-8?B?MW5IMkgxTUVZUWJ3djJZOEJ6Rlk2Zy9hQkswNGREUXJDeTZYdW5IQTlNRHVU?=
 =?utf-8?B?aU5LS0kyRmJRK1A0TUtwc05BeVQ4VEZKeVAxTzJ5bFdQdzh1eWlEOXNZTjBK?=
 =?utf-8?B?KzNSWnVidGFEMkgzTVcyM1I2Tys5U1JBbFByQVk5bHl3bHdXU2tUb0gzNUth?=
 =?utf-8?B?TDJhaklqK3JOcy92T0JteVNPeXBqeTBKNDBxSTRZaVBIWjM0cWpRSmNITlJ4?=
 =?utf-8?B?eWVOTVF4a1VhNUJTSUl4YTBPczMyTUVPamNNSWpVRFJtaXZlUmNTQUY0a042?=
 =?utf-8?B?YThJRCticG1hc3QxOEg2UXluelRwS0hrNDVmTzZKYU1RUm5tVkNQMWNhRkZj?=
 =?utf-8?B?MGtORzFGcmw4R042aHdKUHhPeFloWXUySG1JaTdyazR5Y1h2bHJVUU40akhY?=
 =?utf-8?B?SG9IN1ViSlhudjMvSzFWRm8vOTQyUFdkcXdyVFNmVGF0WU10enBQMEt6M2tG?=
 =?utf-8?B?ZmpRWTFjTzlqOTBqN1A0U2ExY2dtdjRYS3hQOEpFWXA1VHI4ZFc1bUZnWGFQ?=
 =?utf-8?B?TXNGU1dCMzAwVkN4SG1PQXJuZEg5elJDSVFNSWNseGFPci9aU2t4T3hqSmFv?=
 =?utf-8?B?WGVjc2IrWnZxbGlKOGZoS20wMEdsMTFTTDBOYVNyTEsvL0s3Zm9VTVpKM2tU?=
 =?utf-8?B?Nm9BS20waFZpR1F2dUhaUi9CZFFtdEdCbXNLam5EdGJmdHR0b3Z0MVUvWlJu?=
 =?utf-8?B?YWk1amY5Umo4RmZQMzkxNlNmbjMrc3N1QytTOHhJSDVNQVUwRWVLQU5rRjNE?=
 =?utf-8?B?eHFMaUxaMHFNdUowMkZZblJqYWNpTllZdDRHNUd1dEx5dlZZL3p5blIwRml3?=
 =?utf-8?B?YitmOW9hOXR5U0dPc25DQW44ckFVQ2NpSWRoN3dOcGx5TEJuUFZZZWxxdHdX?=
 =?utf-8?B?bmdiaWIwUVFLcFEydCsrZzNqVTJpNzhVZEIzZlRwTjZlY0pGMUpZbU5lQUtj?=
 =?utf-8?B?Q2pYb1E1UnZzNG9HQ3o0WGdTMXNhZGgzSm5hUnpGeExuTGJuYW45K09xN21s?=
 =?utf-8?B?Tlg4S3dzQ0pIbEVZZUxxd0tyQWh4aU1YZFNQZWNVUWtuR3l6SlhRb0t4UkE0?=
 =?utf-8?B?R3FIN0RFK1RNdkxGY25kQS9zWXliMGxrYVdBU1FVazMyUUlJSld3WVp1czBx?=
 =?utf-8?Q?o+XFm3?=
x-forefront-antispam-report: CIP:255.255.255.255; CTRY:; LANG:en; SCL:1; SRV:;
 IPV:NLI; SFV:NSPM; H:DM6PR18MB3667.namprd18.prod.outlook.com; PTR:; CAT:NONE;
 SFS:(13230040)(376014)(366016)(1800799024)(38070700021); DIR:OUT; SFP:1101; 
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0: =?utf-8?B?bysxWkQrOEdMcVdiNTFiV0F1cnlwS1BIOWFDcEM1QS9oclBzUTRtQ0w5OWp4?=
 =?utf-8?B?a3JpZXlPTnBKUFpJcTZJamhSanZPUmdHdVpiQ2xqRVhFN2cyd1JhWE1aekdo?=
 =?utf-8?B?SVBrSU8xMnJCN2R2VloveTNKeUpwM3VsLzF1a3paMldUQU9obi9LQ2VVYUpZ?=
 =?utf-8?B?NkNXRWhxSWxLRDZyMFd3NnNBMVhkbEIxMkRlWXlEQll0VFVJQXFtcjRtSWkx?=
 =?utf-8?B?UFd6elVIZnpDU0lnNi9yR3ZjUmhQcFdWNU40VlUyY0JPcmprWDBZSGF6WWlr?=
 =?utf-8?B?VE84RXU4TlRFSVA1QmMzdkRyMGNRTDZNb203KzVLbDZWR2dZT0VqeUZGQ29y?=
 =?utf-8?B?ODJIeTlDM1c4RDRvSW1TdHFjQmNXazNFb1VwdXR1YVVKZm1kNWIyMWloTVpp?=
 =?utf-8?B?L3cvMDg1R29idVc2dGpMaWhiYUVBcEl1TndYc2ZmK0lyZTFESDY2L2lnZU9k?=
 =?utf-8?B?eW9UTGwyWlVCZFFuTWVKRnFxQ3dCUjNGQXNzODBQb3JFaDA5blRGUlFJaGNn?=
 =?utf-8?B?UlpRV1JXSFdhVGswK3FtZEMzTCs0ZGw5ZG9GUGpiZVk3SUdudllpRUFsbUxk?=
 =?utf-8?B?Wnp4ejFrYlFyaGVLZW5GejRPS0xhakV5eVk5bllQNlhGYVhiWjBpZTRNY2dQ?=
 =?utf-8?B?Q2lVTHovTS9yK0E3SlMyQmFhTWNSYzQ0NUt3L3VmSXBjUTRDZmFMcEQ5VXFS?=
 =?utf-8?B?RlBPM3lLbk43R1FVeGF2ZEFESmlPYUVaQ1VScTV0cmd0WVBKWlB5VmlzWktl?=
 =?utf-8?B?Tk56L1JCSjBSZ01tdEFOcUNVSUtPRTJmZ3U3bStMU01PeFRGMnE0REE5SVFX?=
 =?utf-8?B?dDdIY21MOU9WbUFXQytnR2tscEdGbXpDMXI0OTRodC9kY2dBaDdrejIwL0tD?=
 =?utf-8?B?WEM5dVlTRE9SNG9tQ1hQYjB3Ry9VR0JWaUtqVStGT2lKMGhXN2FBR0syb2Iw?=
 =?utf-8?B?eHhFc1cxMlRxbXBCblh3VnJjdkVRRjMwUEVVL29wd2k1S3RnV2NGN2NXaytW?=
 =?utf-8?B?M3VRaGVwVmNiSVgxR2kxbUYzT3ZHbDYrL2NsNGpqcEZvM2xSWFpSK2gzTHdU?=
 =?utf-8?B?WnFxUkM3eEorMEZ3WngyUS9pQkdOZXQxbTNldVM0dS9IQ3JybU1HbHVDZXIy?=
 =?utf-8?B?Sy9SRGF0eGg0QW1MR0V0cEtJS1E0UTIzdDZMRUJTYWRRQ2M2TUJSbEp6R3pE?=
 =?utf-8?B?ZEp4YUFjNXpZZWhJb3NiYlJVQWJ1ZFdlKzlmc2hHdjlnSUUvZUZXckhHWVZk?=
 =?utf-8?B?M2E5RlAwU3R2MStzamZ1UlArK05QbWJIUmltQWFUc2lOTWVBYkVIekh2WHdZ?=
 =?utf-8?B?clNPWWU4QzNyWlVmaFVuMmZRaGsxQVJ1MzZXNy8rbEFmUWNoNStYU243cTJE?=
 =?utf-8?B?Q25iUFBINEZpZklpV3JST25JbWloUk9zdHBodzY3Q0VoY2NxYStrRS9EY3VX?=
 =?utf-8?B?cTJxcVRYb2NlSHI4SlcxUjNGNTJRRjVvbUNpa25ZdnZ0RXVZSFptYXVGU1JH?=
 =?utf-8?B?T0hlTEt0V3p0dDkvTVUvNUNjR09qMUJ2M2lsUHdkVDBDNm9hc3pDWncySjNP?=
 =?utf-8?B?WUZndjk0Y0YvTlROOGtmQ3ZwNE1HOHV1ZEZrbmRvc3FlbEhSYWlvV2pDS29L?=
 =?utf-8?B?ZXE0S1l5bTh5Q20wcnNMKzYxalhodjVZK2x1elBjanZsekh2TEVPU3RJWVZJ?=
 =?utf-8?B?V2JwZTNIb1JnZWZwRGdhMzVHVzZFYmZZVEFGRjRoM0JNR1c2UjY1aDFnZXR1?=
 =?utf-8?B?N0hQbzZlMHZnU2NGc2c2TUZFbHRmd0lGNGFEblZpcmhGdTZGMHQ0alVpNEdY?=
 =?utf-8?B?SU40dFBkQjkrT29mbzc1NXoxRG5zSnhUUkcyZnk2STdRV0xPZ1BmdEdPK1Zy?=
 =?utf-8?B?bWFQclZ4ZGVBblU0MFk5SXpxSC9uWjYrTHdJL0pzZ1lOZDBsNWtFSHRNV0Nl?=
 =?utf-8?B?c1BSTjQ0KzltVVVnTStpdFBYUE1yaU1PM01sUU9wb1krMUlPVHhsMlFxNFVk?=
 =?utf-8?B?U3dOcitUY1haSGVxeGdIMG9qOWU2TVdpRzM0RG5Eb0ZPYS9LNEQwMnVjOWlC?=
 =?utf-8?B?VXRRTWo1TGhJeW9UVVc4TExyWnFuK0JxR0FXUXRFWDAvV2NpVGdoUmVuOWk4?=
 =?utf-8?Q?7CoGcSMdDauKtrPjpa33ZReUb?=
Content-ID: <289BCC7D4E1F56478A05527D775328AC@namprd18.prod.outlook.com>
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: DM6PR18MB3667.namprd18.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: c41b930b-2188-42ae-08e7-08de1be6bf54
X-MS-Exchange-CrossTenant-originalarrivaltime: 04 Nov 2025 21:11:39.9288 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 5280104a-472d-4538-9ccf-1e1d0efe8b1b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: Ag+rlF2q8PayUklX8r7j4nox0kVox0GYxHqXqpI0xu7k0FKUJoi7z5pSORHTMrItmLqPkPQYJWt2X8KoFNy1VQ==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: CH3PR18MB6119
X-OriginatorOrg: amazon.com
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
From: "Day, Timothy via lustre-devel" <lustre-devel@lists.lustre.org>
Reply-To: "Day, Timothy" <timday@amazon.com>
Cc: Lustre Development List <lustre-devel@lists.lustre.org>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

Pj4+IEdlbmVyaWMgTHVzdHJlIHV0aWxpdGllcyB3b27igJl0IGJlIGFibGUgdG8gZGlyZWN0bHkg
YWNjZXNzIHNwaWxsaW5nDQo+Pj4gZGV2aWNlcy4gRm9yIGV4YW1wbGUsICoqbGZzIGRmKiogd2ls
bCBvbmx5IGRpc3BsYXkgdGhlIGNhcGFjaXR5IG9mIHRoZQ0KPj4+IE9TRCBkZXZpY2UsIHdoaWxl
IHRoZSBjYXBhY2l0eSBvZiB0aGUgc3BpbGxpbmcgZGV2aWNlIGNhbiBiZSBhY2Nlc3NlZA0KPj4+
IHVzaW5nIHNwZWNpZmljIG9wdGlvbnMuDQo+Pg0KPj4gSSBkb24ndCBzZWUgd2h5IHRoZXJlIGhh
cyB0byBiZSBhIHNlcGFyYXRpb24gYmV0d2VlbiB0aGUgc3BpbGwgZGV2aWNlDQo+PiBhbmQgdGhl
IE9TRCBkZXZpY2UuIEkgdGhpbmsgaXQncyBhIHNpbXBsZXIgZXhwZXJpZW5jZSBmb3IgZW5kLXVz
ZXJzDQo+PiBpZiB0aGVzZSBkZXRhaWxzIGFyZSBoYW5kbGVkIHRyYW5zcGFyZW50bHkuIElkZWFs
bHksIGFsbCBvZiB0aGUgdGllcmluZw0KPj4gY29tcGxleGl0eSB3b3VsZCBiZSBoYW5kbGVkIGJl
bG93IHRoZSBPU0QgQVBJIGJvdW5kYXJ5LiBMdXN0cmUgaXRzZWxmDQo+PiBpLmUuICJ0aGUgdXBw
ZXIgbGF5ZXJzIiBzaG91bGRu4oCZdCBuZWVkIHRvIG1vZGlmaWVkLg0KPg0KPlllYWggZG8gbm90
IHRvdWNoIHRoZSB1cHBlciBsYXllciBpcyBvbmUgb2YgdGhlIGdvYWxzLiBCeSBkZXNpZ24sIHNw
aWxsIGRldmljZSBpcyBhIHBpZWNlIG9mIHByaXZhdGUgaW5mb3JtYXRpb24gdG8gdGhhdCBwYXJ0
aWN1bGFyIE9TRCwgdGhlIHJlc3Qgb2YgTHVzdHJlIHN0YWNrIHdvbuKAmXQgYmUgYWJsZSB0byBz
ZWUgaXQuDQoNCldlIHdvdWxkIHNvbWVob3cgZXhwb3NlIHRoZSBleGlzdGVuY2Ugb2YgdGhlIHNw
aWxsIGRldmljZQ0KdmlhIGBsZnMgZGZgLCBzbyB0aGUgc3RhdCBmcm9tIGNsaWVudCB0byBzZXJ2
ZXIgd291bGQgaGF2ZSB0byBjaGFuZ2U/DQpBbmQgeW91IG1lbnRpb24gc29tZSBkaWZmaWN1bHR5
IHN1cHBvcnRpbmcgczNmcy9nY3NmdXNlDQp3aXRoIE9GRC4gU28geW91IGFudGljaXBhdGUgYXQg
bGVhc3Qgc29tZSB1cHBlciBsYXllciBjaGFuZ2VzPw0KDQo+Pj4gT1NEcyB3aWxsIGFjY2VzcyBz
cGlsbGluZyBkZXZpY2VzIHRocm91Z2ggVkZTIGludGVyZmFjZXMgaW4gdGhlIGtlcm5lbA0KPj4+
IHNwYWNlLiBUaGVyZWZvcmUsIHRoZSBzcGlsbGluZyBkZXZpY2UgbXVzdCBiZSBtb3VudGFibGUg
aW50byB0aGUNCj4+PiBrZXJuZWwgbmFtZXNwYWNlLiBJbml0aWFsbHksIG9ubHkgSEREIGlzIHN1
cHBvcnRlZCwgYW5kIHRoZQ0KPj4+IGltcGxlbWVudGF0aW9uIGNhbiBiZSBleHRlbmRlZCB0byBT
MyBhbmQgR0NTIHVzaW5nIHMzZnMgYW5kIGdjc2Z1c2UNCj4+PiByZXNwZWN0aXZlbHkgaW4gdGhl
IGZ1dHVyZS4NCj4+DQo+PiBUaGlzIGlzbid0IGNsZWFyIHRvIG1lLiBPbmNlIHdlIHN1cHBvcnQg
SERELCB3aGF0IGluY3JlbWVudGFsIHdvcmsNCj4+IElzIG5lZWRlZCB0byBzdXBwb3J0IHMzZnMv
Z2NzZnVzZS9ldGM/IEFzIGxvbmcgYXMgdGhleSBwcmVzZW50IGENCj4+IG5vcm1hbCBmaWxlc3lz
dGVtIEFQSSwgdGhleSBzaG91bGQgYWxsIHdvcmsgdGhlIHNhbWU/DQo+Pg0KPj4gVGhpcyBiZWdz
IHRoZSBxdWVzdGlvbjogaWYgd2UncmUgYWxyZWFkeSBkb2luZyB0aGlzIHdvcmsgdG8gc3VwcG9y
dA0KPj4gd3JpdGluZyBMdXN0cmUgb2JqZWN0cyB0byBhbnkgYXJiaXRyYXJ5IGZpbGVzeXN0ZW0g
dmlhIFZGUyBhbmQgd2UncmUgb25seQ0KPj4gaW50ZW5kaW5nIHRvIHN1cHBvcnQgT1NUcyB3aXRo
IHRoaXMgcHJvcG9zYWwsIHdoeSBub3QgaW1wbGVtZW50DQo+PiBhbiBPU1Qtb25seSBWRlMgT1NE
IGFuZCBoYW5kbGUgdGllcmluZyBpbiB0aGUgZmlsZXN5c3RlbSBsYXllcj8NCj4NCj5WRlMgT1NE
IHdvbuKAmXQgZ2l2ZSB1cyBldmVyeXRoaW5nIHRvIG1ha2UgaXQgYW4gT1NELiBUcmFuc2FjdGlv
biBpcyBvbmUgb2YgdGhlIGlzc3VlIGFzIE9sZWcgbWVudGlvbmVkLg0KDQpXZSdsbCBoYXZlIHRv
IGltcGxlbWVudCBhIGxvdCBvZiBjb21wbGV4aXR5IGluIGtlcm5lbCBzcGFjZSBmb3INCnRoZSBk
ZXNpZ24geW91J3JlIHN1Z2dlc3RpbmcuIEF0IHNvbWUgcG9pbnQsIGltcGxlbWVudGluZw0KYSB0
cmFuc2FjdGlvbiBsb2cgYW5kIGRlbGVnYXRpbmcgdGhlIHJlc3QgdG8gdXNlciBzcGFjZSBtaWdo
dA0KYmUgdGhlIG1vcmUgbWFpbnRhaW5hYmxlIG9wdGlvbj8gRG9pbmcgdGhhdCB2aWEgVkZTL0Z1
c2UgaXMNCm9uZSBvcHRpb24uIFNvbWV0aGluZyBzaW1pbGFyIHRvIHVibGsgZm9yIE9TRCBjb3Vs
ZCBiZSBhbm90aGVyDQpvcHRpb24uDQoNCkknbSBub3Qgc2F5aW5nIHRoaXMgaXMgcHJlZmVycmFi
bGUsIGJ1dCBpcyB0aGlzIHNvbWV0aGluZyB5b3UndmUNCmNvbnNpZGVyZWQ/DQoNCj4gIEV4dGVu
ZGVkIGF0dHJpYnV0ZXMgd291bGQgYmUgYW5vdGhlciB0aGluZyBzaW5jZSBub3QgYWxsIGZpbGUg
c3lzdGVtcyB3b3VsZCBzdXBwb3J0IGl0Lg0KDQpJIHRoaW5rIGl0J3MgZmluZSBub3QgYWNjZXB0
IGZpbGVzeXN0ZW1zIHRoYXQgZG9uJ3Qgc3VwcG9ydCBFQS4gT3IgaGF2ZSB0aGUNCk9TRCBhZHZl
cnRpc2UgdGhhdCBpdCBkb2Vzbid0IHN1cHBvcnQgRUEuDQoNCj4+PiBUaGVyZeKAmXMgbm8gb24t
ZGVtYW5kIG1pZ3JhdGlvbiBmZWF0dXJlLiBJZiB0aGVyZeKAmXMgbm8gYXZhaWxhYmxlIHNwYWNl
DQo+Pj4gd2hpbGUgYSBsYXJnZSBjaHVuayBvZiBkYXRhIGlzIGJlaW5nIHdyaXR0ZW4sIHRoZSBz
eXN0ZW0gd2lsbCByZXR1cm4NCj4+PiBFTk9TUEMgdG8gdGhlIGNsaWVudC4gVGhpcyBzaW1wbGlm
aWVzIHRoZSBncmFudGluZyBtZWNoYW5pc20gb24gdGhlDQo+Pj4gT0ZEIHNpZ25pZmljYW50bHku
IEFub3RoZXIgcmVhc29uIGZvciB0aGlzIGFwcHJvYWNoIGlzIHRoYXQgd3JpdGluZw0KPj4+IHBl
cmZvcm1hbmNlIGlzIG1vcmUgcHJlZGljdGFibGUuIE90aGVyd2lzZSwgdGhlIHN5c3RlbSBtaWdo
dCBoYXZlIHRvDQo+Pj4gd2FpdCBmb3IgYW4gb2JqZWN0IHRvIGJlIG1pZ3JhdGVkIG9uIGRlbWFu
ZCwgbGVhZGluZyB0byBtdWNoIGhpZ2hlcg0KPj4+IGxhdGVuY3kuDQo+Pg0KPj4gSSB0aGluayB1
c2VycyB3b3VsZCB0b2xlcmF0ZSBzbG93IGpvYnMgbW9yZSB0aGFuIHdyaXRlIGZhaWx1cmVzIGJl
Y2F1c2UNCj4+IHRoZSBPU0QgaXNuJ3Qgc21hcnQgZW5vdWdoIHRvIHdyaXRlIHRvIHRoZSBlbXB0
eSBzcGlsbCBkZXZpY2UuDQo+DQo+VGhlIG9ubHkgcmVhc29uIHRoYXQgdXNlciB1c2VzIEx1c3Ry
ZSBpcyBiZWNhdXNlIG9mIHBlcmZvcm1hbmNlLiBJZiBhIG1pc2NvbmZpZ3VyYXRpb24gd291bGQg
bGVhZCB0byAxMDAgc2Vjb25kcyBvZiBsYXRlbmN5LCB0aGF0IGlzIGRlZmluaXRlbHkgbm90IHRo
ZXkgd291bGQgZXhwZWN0LiBUaGlzIHByb2R1Y3QgaXMgbm90IGRlc2lnbmVkIGZvciA+dGhhdCB1
c2UgY2FzZS4NCg0KU28gaWYgeW91IHdhbnQgdG8gd3JpdGUgZmFzdGVyIHRoYW4gdGhlIG1pZ3Jh
dGlvbiBkYWVtb24gY2FuDQpmcmVlIHNwYWNlLCB5b3UgaGF2ZSB0byBhY2NlcHQgYSB3cml0ZSBm
YWlsdXJlPyBJIGNhbid0IHJlYWxseQ0KdGhpbmsgb2YgYSB3b3JrbG9hZCB3aGVyZSB0aGlzIGlz
IHByZWZlcmFibGUuIEkgdGhpbmsgdGhpcw0KYmVoYXZpb3Igc2hvdWxkIGJlIHR1bmFibGUsIGF0
IGxlYXN0Lg0KDQo+Pj4gZGVsaXZlciBiZXR0ZXIgcGVyZm9ybWFuY2UgdGhhbiBibG9jay1sZXZl
bCBjYWNoZSB3aXRoIGRtY2FjaGUsIHdoZXJlDQo+Pj4gcmVjb3ZlcnkgdGltZSBpcyBsZW5ndGh5
IGlmIHRoZSBjYWNoZSBzaXplIGlzIGh1Z2UuDQo+Pg0KPj4gVGhpcyBzZWVtcyBzcGVjdWxhdGl2
ZS4gQ291bGQgeW91IGVsYWJvcmF0ZSBtb3JlIG9uIHdoeSB5b3UgdGhpbmsNCj4+IHRoaXMgaXMg
dGhlIGNhc2U/DQo+DQo+IERNY2FjaGUgZG9lc27igJl0IHBlcnNpc3QgdGhlIGJpdG1hcCB1c2Vk
IHRvIGluZGljYXRlIHdoaWNoIGJsb2NrcyBhcmUgaG9sZGluZyBkaXJ0eSBkYXRhLCBzbyBhbiB1
bmdyYWNlZnVsIHNodXRkb3duIHdpbGwgbGVhZCB0byBhIHNjYW5uaW5nIG9mIHRoZSBlbnRpcmUg
Y2FjaGUgaW4gb3JkZXIgdG8gZGV0ZXJtaW5lIHdoaWNoIGJsb2NrcyBhcmUgPiBkaXJ0eS4NCg0K
VGhpcyBpcyBhIGZhaWxpbmcgb2YgRE1jYWNoZSByYXRoZXIgdGhhbiBhbiBpbmRpY2F0aW9uIHRo
YXQgdGhpcw0KcHJvYmxlbSBjYW4ndCBiZSBzb2x2ZWQgb24gdGhlIGJsb2NrIGxheWVyLg0KDQpP
dmVyYWxsLCBJIHRoaW5rIHRoZSBjb25jZXB0IGlzIGludGVyZXN0aW5nLiBJdCByZW1pbmRzIG1l
IG9mIGhvdw0KQmNhY2hlZnMgaGFuZGxlIG11bHRpLWRldmljZSBzdXBwb3J0LiBFYWNoIGRldmlj
ZSBjYW4gYmUNCmRlc2lnbmF0ZWQgYXMgaG9sZGluZyBtZXRhZGF0YSBvciBkYXRhIHJlcGxpY2Fz
LiBBbmQgeW91DQpjYW4gY29udHJvbCB0aGUgcHJvbW90aW9uIGFuZCBtaWdyYXRpb24gYmV0d2Vl
biBkaWZmZXJlbnQNCnRhcmdldHMgKGFsbCBtYW5hZ2VkIGJ5IGEgbWlncmF0aW9uIGRhZW1vbiku
IEJ1dCB0aGlzIGRlc2lnbiBpcw0KdG9vIGxpbWl0ZWQsIElNSE8uIElmIHdlJ3JlIGdvaW5nIHRv
IGFjY2VwdCB0aGUgYWRkaXRpb25hbCBjb21wbGV4aXR5DQppbiB0aGUgT1NELCB0aGUgc29sdXRp
b24gaGFzIHRvIGJlIGV4dGVuc2libGUuIFdoYXQgaWYgSSB3YW50IHRvDQpyZXBsaWNhdGUgdG8g
bXVsdGlwbGUgdGFyZ2V0cz8gV2hhdCBpZiBJIHdhbnQgbW9yZSB0aGFuIHR3byB0aWVycz8NCldo
YXQgaWYgSSB3YW50IHRvIHRyYW5zcGFyZW50bHkgbWlncmF0ZSBkYXRhIGZyb20gb25lIHNwaWxs
IGRldmljZSB0bw0KYW5vdGhlcj8gV2UgZG9uJ3QgbmVlZCB0aGlzIGZvciB0aGUgaW5pdGlhbCBp
bXBsZW1lbnRhdGlvbiwgc3VyZS4NCkJ1dCB0aGVzZSBzZWVtIGxpa2UgbmF0dXJhbCBleHRlbnNp
b25zLg0KDQpJIHRoaW5rIHdlIG5lZWQgdG8gdXNlIHNvbWUga2luZCBvZiBjb21tb24gQVBJIGZv
ciB0aGUNCmRpZmZlcmVudCBkZXZpY2VzLiBFdmVuIGlmIHRoZSBzcGlsbCBkZXZpY2UgZG9lc24n
dCBzdXBwb3J0IGF0b21pYw0KdHJhbnNhY3Rpb25zLCBJIGRvbid0IHNlZSB3aHkgd2UgY291bGRu
J3Qgc3RpbGwgdXNlIHRoZSBjb21tb24gT1NEDQpBUEkgYW5kIGltcGxlbWVudCB0aGUgbWlncmF0
aW9uIGRhZW1vbiBhcyBhIHN0YWNraW5nIGRyaXZlciBvbi10b3ANCm9mIHRoYXQuIFRoZSBzcGls
bCBkZXZpY2UgT1NEIGRyaXZlciBjb3VsZCBiZSBtYWRlIHRvIGFkdmVydGlzZSB0aGF0IGl0DQpk
b2Vzbid0IHN1cHBvcnQgYXRvbWljIHRyYW5zYWN0aW9ucyBhbmQgbWF5IG5vdCBzdXBwb3J0IEVB
LiBCdXQgd2UNCmdldCB0aGUgYWRkZWQgYmVuZWZpdCBvZiBiZWluZyBhYmxlIHRvIHVzZSBleGlz
dGluZyBPU0RzIHdpdGggdGhpcw0KZmVhdHVyZSwgcHJldHR5IG11Y2ggZm9yIGZyZWUuDQoNCl9f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fCmx1c3RyZS1kZXZl
bCBtYWlsaW5nIGxpc3QKbHVzdHJlLWRldmVsQGxpc3RzLmx1c3RyZS5vcmcKaHR0cDovL2xpc3Rz
Lmx1c3RyZS5vcmcvbGlzdGluZm8uY2dpL2x1c3RyZS1kZXZlbC1sdXN0cmUub3JnCg==
