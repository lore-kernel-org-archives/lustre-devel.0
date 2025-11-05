Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id A8BD2CCFA0D
	for <lustre-devel@archiver.kernel.org>; Wed,  5 Nov 2025 17:40:49 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4d1szd3fxNz1yXg;
	Wed, 05 Nov 2025 09:40:29 -0800 (PST)
Received: from iad-out-008.esa.us-east-1.outbound.mail-perimeter.amazon.com
 (iad-out-008.esa.us-east-1.outbound.mail-perimeter.amazon.com
 [34.193.58.168])
 (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4d1szF3Tsfz1xFK
 for <lustre-devel@lists.lustre.org>; Wed, 05 Nov 2025 09:40:09 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=amazon.com; i=@amazon.com; q=dns/txt; s=amazoncorp2;
 t=1762364409; x=1793900409;
 h=from:to:cc:date:message-id:references:in-reply-to:
 content-id:content-transfer-encoding:mime-version:subject;
 bh=KLtK7+Dnf3RpdmVMFctwtD1g+tYAsJoirl81ngpBeXU=;
 b=QC7lkyj2d+S10EqA1c+lHZ/443hXtIQuoJx9rDJefG47gYb6jMGWJ4y3
 lp9rs/v0OlwJ0Q/0N/TaCWizEb/acFd5xi5fwAx40GGqrGjb10BYcCqXV
 bvWPH98AscfPStTkpEZV30mO8fIadVBSNCv/j3FR03+b+Z1dQe1sfgsp2
 wh+3JcjBNPQJFS7WMUQxf3pe2F/wlL9ksWRLRl5FYsvoIV0RHTIPkkQ9f
 gLRUp0NxZbow5sqbfsE5/k4uXMgAHWewHR2fmC1sBiOPXfRWJS/pK13Db
 xUbwv9+JwL15aH/Zi+Kt76bJJoVTDsLR7wBy4+TDf+kIqiBScEduZCfLo Q==;
X-CSE-ConnectionGUID: LpxEFVvRSEyC3M7btvqeqA==
X-CSE-MsgGUID: Rt/bZGtoQii0TEZq8tQZpQ==
X-IronPort-AV: E=Sophos;i="6.19,282,1754956800"; 
   d="scan'208";a="5639862"
Thread-Topic: RFC: Spill device for Lustre OSD
Received: from ip-10-4-10-75.ec2.internal (HELO
 smtpout.naws.us-east-1.prod.farcaster.email.amazon.dev) ([10.4.10.75])
 by internal-iad-out-008.esa.us-east-1.outbound.mail-perimeter.amazon.com with
 ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 05 Nov 2025 17:40:08 +0000
Received: from EX19MTAUEB001.ant.amazon.com [72.21.198.67:24600]
 by smtpin.naws.us-east-1.prod.farcaster.email.amazon.dev [10.0.9.56:2525] with
 esmtp (Farcaster)
 id 6628713a-eccc-43d0-a473-9d0b57c31926; Wed, 5 Nov 2025 17:40:08 +0000 (UTC)
X-Farcaster-Flow-ID: 6628713a-eccc-43d0-a473-9d0b57c31926
Received: from EX19EXOUEB001.ant.amazon.com (10.252.135.46) by
 EX19MTAUEB001.ant.amazon.com (10.252.135.108) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA) id 15.2.2562.29;
 Wed, 5 Nov 2025 17:40:06 +0000
Received: from DS2PR08CU001.outbound.protection.outlook.com (10.252.134.239)
 by EX19EXOUEB001.ant.amazon.com (10.252.135.46) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA) id 15.2.2562.29
 via Frontend Transport; Wed, 5 Nov 2025 17:40:06 +0000
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=dc3o13OLPJWKpSEWs2wp6s84YOgsgN/rfIup2D2qDBpuIzHButW/PKNdTaOjBsjDQa/CMcAd3B+NP905qiZpzaay6biLggwHq20/XguaIkOopHD/6qvswHrzBJVs+3+0LT2AR3TkiaL8WmDzEoz4Ja0OvW+BnL+zuxwv6gjOv9iRwJKtnH5B0csXZBVFFtLMagbASLU13BUDOboUdNmU6018OhMgUHZ5F/0M9zfXqATg+wTEj36kG8ssyEd6sBCwBZpQbmmkf/Q2jj7We7bMV7cIWGY7FXngmKhFNPVnIIUneQCiAQRSRhMoUS+LtW4xwgHeMhknz+TZ4xOxEZcmsQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com; 
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=KLtK7+Dnf3RpdmVMFctwtD1g+tYAsJoirl81ngpBeXU=;
 b=xncctmpaCAH4D3ib5iJ9Wjf9aLWfvyOPb7lD6c1cgfxDGmn/llpQbNF8v7yA2mogMaje/XGT7uPGvl+TkFSMkznDAgpkkb5l237k3ADtEhGesGAdCCndM82zxMV0bq1Fwx8I8S/dQPOLio47vrJcLDdA3FSTCgpNp9Qg2colOMPUeofVMl2oAdbJrgusadndZx0aafJxMYoNG/lBcZipHUeVY5sevpWq6Vrag5/JA7MsSCpUDhcfoqT0Te9+QxhbFujbE8zqOEDBrUrZJ+Rj/Ydr8LQnYRyoRrpOq2OKbMzIpc+DvDOKwW1TPVozQXzdAqg/OVfcwIKlnImF2JE2hg==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=amazon.com; dmarc=pass action=none header.from=amazon.com;
 dkim=pass header.d=amazon.com; arc=none
Received: from MW3PR18MB3673.namprd18.prod.outlook.com (2603:10b6:303:57::17)
 by SJ2PR18MB5586.namprd18.prod.outlook.com (2603:10b6:a03:565::20)
 with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.9275.16; Wed, 5 Nov
 2025 17:40:04 +0000
Received: from MW3PR18MB3673.namprd18.prod.outlook.com
 ([fe80::6fdf:14ef:c694:58d9]) by MW3PR18MB3673.namprd18.prod.outlook.com
 ([fe80::6fdf:14ef:c694:58d9%5]) with mapi id 15.20.9298.007; Wed, 5 Nov 2025
 17:40:04 +0000
To: Jinshan Xiong <jinshan.xiong@gmail.com>, Andreas Dilger <adilger@ddn.com>
Thread-Index: AQHcTE/AGdVndrjiSE2WWCbdtaJ3z7ThLbQAgAB1AQCAARASgIAAdBYAgAAJ7QCAANk0AA==
Date: Wed, 5 Nov 2025 17:40:04 +0000
Message-ID: <7CCCF89D-E3E5-4FCB-BFBB-4E6129BC8303@amazon.com>
References: <CFE3C4C8-104E-4F7F-A52E-21B8957FAC0F@amazon.com>
 <0092A54A-6EEF-4CD3-8AFD-7B0066A08810@gmail.com>
 <D8E0F0C0-1A5F-413A-82EA-F3CFA473D2E1@amazon.com>
 <28B74585-1877-4A33-9218-FD50AE72D33D@ddn.com>
 <74326E79-3FCD-41F5-B5DA-95EA2CC48435@gmail.com>
In-Reply-To: <74326E79-3FCD-41F5-B5DA-95EA2CC48435@gmail.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
msip_labels: MSIP_Label_19e68092-05df-4271-8e3e-b2a4c82ba797_Enabled=true;
 MSIP_Label_19e68092-05df-4271-8e3e-b2a4c82ba797_SetDate=2025-11-05T16:21:31Z;
 MSIP_Label_19e68092-05df-4271-8e3e-b2a4c82ba797_ContentBits=0;
 MSIP_Label_19e68092-05df-4271-8e3e-b2a4c82ba797_Enabled=true;
 MSIP_Label_19e68092-05df-4271-8e3e-b2a4c82ba797_Tag=50, 3, 0,
 1; MSIP_Label_19e68092-05df-4271-8e3e-b2a4c82ba797_Name=Confidential;
 MSIP_Label_19e68092-05df-4271-8e3e-b2a4c82ba797_ActionId=28d3e873-5735-4b1e-a0ac-1a1202590baa;
 MSIP_Label_19e68092-05df-4271-8e3e-b2a4c82ba797_SiteId=5280104a-472d-4538-9ccf-1e1d0efe8b1b;
 MSIP_Label_19e68092-05df-4271-8e3e-b2a4c82ba797_Method=Standard; 
authentication-results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=amazon.com;
x-ms-publictraffictype: Email
x-ms-traffictypediagnostic: MW3PR18MB3673:EE_|SJ2PR18MB5586:EE_
x-ms-office365-filtering-correlation-id: 702633e9-d56c-451c-3b0d-08de1c925ace
x-ms-exchange-senderadcheck: 1
x-ms-exchange-antispam-relay: 0
x-microsoft-antispam: BCL:0; ARA:13230040|376014|366016|1800799024|38070700021;
x-microsoft-antispam-message-info: =?utf-8?B?YVFLUGQzNFN1OEd0cCtqRldmMUU5Um92WFpsZmZCRm1iL2REbmV4cE52R3B2?=
 =?utf-8?B?Ti9ZRTNTT2NEUDkvRmNPRStMdFh4YmVjVExnQ09GL0pESWhYTVNueFRjYzB1?=
 =?utf-8?B?YWh4VXJHMi81RnlWeUZrcEFDSHVZU3pXRjdiY1dVQWtwL0dnYTVjbVMzcGhG?=
 =?utf-8?B?aWlCZWRscjRsUHpTVVBUbm94RGtvYnp2ZnpBbG16dEpGYXVONmxlaVgvU2tv?=
 =?utf-8?B?TDd4VGNhdGZRTkY5VkI0MExLV0xHQy9QaWh5U3kzOU9PSEZLZFZ2ZHVkMXpJ?=
 =?utf-8?B?ZENxVFlkNFg2YlY4NWwydHNMZmIrTzZlczIvTS9nQmlYVGVIZEFZUUE4cVpS?=
 =?utf-8?B?VHg4U3Y4RFpXVFNjeVFvR2s1cmJadTFsa1ErZTlFRU9CbmM1QUZqY0lPWGJH?=
 =?utf-8?B?LytqZ3IwOHg0Qy8xeDB4Y3FkQ0R2MW1yNDVOTE9WeFkvbk5Ub0Yra1IrNmJW?=
 =?utf-8?B?QWdtbFhjb29Xa2JtaWNlSWZ6ZTNzMjFNVk1PcGdDakxiY1hTS3crcm42V3pv?=
 =?utf-8?B?T1hVSHFzdW5aT3BWTUVUUkRsa1NxZmgwS3E4V3NvNXVnSFcrSFd1aUE5RUo2?=
 =?utf-8?B?eCtWT044cjhtSzJMTzliTEJCbWxDbjQ2T2E4dlQvb0svMTVvVTFWVnNxVng0?=
 =?utf-8?B?bFlMUkZqODVtVVhOQVBaV3pWSVZyODd5RWtaQjVpbWh5TS9kSFRJamZLbGJw?=
 =?utf-8?B?SE14RVdMUUJISkl5MXppV0NVakt3bnFoNFBzQWZUMGVVVVB6UXNFZm5GQzVC?=
 =?utf-8?B?emRQT1VIOXo5VkJtNWo4dGZ5ZGR4K2Jjb1ZHdzU0TFN1Q08zeWNTd0VrcUd3?=
 =?utf-8?B?QzJ3MjZxbFhVK3JFMjlQUnRZaW5PY2NaUTZHNW5wN0x6VitmTlk3TGg1ZmpE?=
 =?utf-8?B?NnNRUk9aNDBrakdOVGxDYkkwSVdWTyt5SjVpb1B4UHR0SkpTaTltK1RuNy8r?=
 =?utf-8?B?VnpMby92Qkx3YUZ3SndPN0dPMzhNLzVwTXZHc2Y2QzZDdVBCUGpUVkt0akdI?=
 =?utf-8?B?MGlBeFV2Q1pJVHA3SFlVc3FjVk9HTVRxTDdvTkM5REswSml5VmVBNHV5cXhK?=
 =?utf-8?B?Rnp3dHVyNFczMzV2dW9LT3JHd1FLY1pxWTF1L3lwRFlLc3g0YmEvSS81bXV5?=
 =?utf-8?B?c1J0eDlhTkhKalNWNm4xdml2V1U0M2dRdjhZS3VGMVJEMmhuRVpLWHdveFQx?=
 =?utf-8?B?enFxdG1vMlF5Z0hrV0V3a2NUempIb05lK1NlSUdCSldYKzJqUVgwTUhocGpI?=
 =?utf-8?B?ZWtBREJjWC9kSjRqT2Q5ckgxNGNLbCtYWVBrSE1pNldTV0FNb1JZMEFQbDFp?=
 =?utf-8?B?NmF4ajhSZEMyQ3lZR3FTZFZlMVl5dC85M29abGl2c3NnTG94Rmg2VkZ6VWw3?=
 =?utf-8?B?cC8vaVNaZENkbGlYbURnUkMxRThXLzZ1TkhqMnh6WGNIam9SdTcvVVduS3Ni?=
 =?utf-8?B?bEwvWHZkM01BOWpISnhrTUNRbC9UUFovY0dIVlhrRDkyWTdGYmIvaG12M0ZR?=
 =?utf-8?B?Tlg2RnAyc0IzS0xkV2YzZnRpMHRaOTlYUVBEbVordDZid01LZThHQnY4cFdy?=
 =?utf-8?B?TThkZHY0UWhLeGhvalVFOFVLNnhJTEhUYUpwNWdDS3lZdk5oekhQb200ckFZ?=
 =?utf-8?B?SVlCYVNIamZnOGd2T2srK1BEckJjWFVNdU5xd3R3UkpXcXJYY2htVnpNM0Rs?=
 =?utf-8?B?a2IwRGphK0laZXdtOGppc0lINERhNlplSzBJZlF2Qzlhd1VicUJmM2VDTEU0?=
 =?utf-8?B?OTZOV1ZxMERDNythK1ZWR2NKVC9CMTVQV1c4MW1mSXR5VWorSnJXZzFic1Jz?=
 =?utf-8?B?MDhCN0NIcFFzVHVMRW0vVVF5Uy93MmVrRUp1cjNvbDFiQ3FiVEpoZ3cxcm5J?=
 =?utf-8?B?NzhxWlk1YmxoMmJ6em5lVU4vSFhsWUo5OG1ZWVFnNGJRaTY0Zm5xcFpwYWNz?=
 =?utf-8?B?bUptWkg3Vjl1Ym8yMEFVZzJyelNpVDJubDI0eVNXdXc3RjR1Sml1ODAzYmpa?=
 =?utf-8?B?TGpPQ0QwSFJjblhDdkNjMVFzbkFqMndDTVlDNlFsZ29BS0U2QmhQREdWa3g1?=
 =?utf-8?Q?LhMboi?=
x-forefront-antispam-report: CIP:255.255.255.255; CTRY:; LANG:en; SCL:1; SRV:;
 IPV:NLI; SFV:NSPM; H:MW3PR18MB3673.namprd18.prod.outlook.com; PTR:; CAT:NONE;
 SFS:(13230040)(376014)(366016)(1800799024)(38070700021); DIR:OUT; SFP:1101; 
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0: =?utf-8?B?cVdRSDFDTXRoM0FwdUE1d24yRUttaEIreENteDhJYTFIUldjYURNc0w0OXFm?=
 =?utf-8?B?UlF2dW01Wlh5T0tTaTE3L0NxYmY2Ky8rR05Qa2dySDFYeVFhYUM3R2hKQlBJ?=
 =?utf-8?B?bDF2akRHMER3all2VHZIVnR0a1BoQ3ZzVjRtSFE0SnBjK2VYZFNZSWdCQjVu?=
 =?utf-8?B?MVZTUVE4K21DVTVqSkJHMU9XOGNOMWljWWpBbnFiTUk0cDdxOS9PUE0xVHFW?=
 =?utf-8?B?SFR4YjVXUW00MWc1VW1IMlVVK2x1N28zRXE5UzZmUno4M2s1MEx5dmhaTmsr?=
 =?utf-8?B?bng3OGg1L3lWZEVUTnFmYldqcEN3S1ZyOHRRc2VtcUJpdndxekhSeGs1V1FY?=
 =?utf-8?B?b2g1akZyYzFKYk1LQ2Z4WUFSMHBCL3BmYzhGK2xFNlFFcG1seG42RmorcWJV?=
 =?utf-8?B?elNZZlBUV2lBWmtoUFM1RVRiTEIvUUdYakZFZ2RmaTR2WEdsSkhhd1VRUjM1?=
 =?utf-8?B?bFgrVk9BWnVsRmM0Qnk3YkJyeTdrV3JKbnFMNGV6UEFjdmZZNDhZNHhBSVJ0?=
 =?utf-8?B?Y1MySkJNUVVCb1Y4Yno1VDMvTExiVEpldTBMRStXdzRpcFVpUnVZallUazM1?=
 =?utf-8?B?MTBzOGp0RVRReFJUTk9qUnJWT1J2ZTdreVg0SGo3S2Y4QkhIT254dERrUnhJ?=
 =?utf-8?B?Y0s3cjd5UG5FOXpkeU14SUhLSmxIV1FSQzZFbXhyUHRyUDY5RE9rWStscU9X?=
 =?utf-8?B?bEFqQ0FJU2tQRGxwdmxaTnBNSXMxN3FObFFKQlJpN2dQd2tjaVl2RlVWUlMx?=
 =?utf-8?B?Q2xqTy9VTkpnZkJ6YnpMSmlzT0JDaEtUellZOTJ2UGFIY2pTd3J5NG1KU3A4?=
 =?utf-8?B?eE1vNVZzMDZCVFN5c3BPV2t5UHJtS1NFaGxNNDlleFRGbDhCaGZOVEtkeVVw?=
 =?utf-8?B?VUQ0YTZZODN1V0NQUmNxZENRQzRBc0xIR3I1eEtGeFZlNGJBTVM3bE1vNkUv?=
 =?utf-8?B?WFVnUEZpcVZFelB1aGExbnBIbGM1Y2tRakxxZ0NoZ0Uya0FyLzM4TmNaZS9u?=
 =?utf-8?B?bnk1SDdzczMxNEVyRWt5dHg1OHlXWUFQQ21qTkRtVlcxN3ZOM1pjYkxvZzJI?=
 =?utf-8?B?bVppT0FLZ3ZEeUgySWQyajBIZktVdDBaNW40MjZFemp6Uy9naXg5bjhZWTIw?=
 =?utf-8?B?bVNvUDNZMjUzOW9CclYvenk3WEVKUnZjTFRHVkJrd2NKdnRHVjBLdnY1dG1r?=
 =?utf-8?B?U0s1OUZ1UHBwMDl3Zk5UVkNsOEk1bXFHWG5XeXVaN3lyNkIrQmFQL2ZXMUNT?=
 =?utf-8?B?TCtrSEE5YzhjQkU1UnhFREdqWHlyTjBPWFVjTHlzNEQ0WG12Z1JtRGo0TVdW?=
 =?utf-8?B?a3IzajVSc2xHYVltTVlGT2NScFRtclZYb1ViUm5MYmd0MzJJNnpUOWN2SnJF?=
 =?utf-8?B?K2ZjTXNEcHJ1ZnJ2UDA1ODY2ckcweVdoK1E1WGhOMEd5RUYySGtONjRBcmJV?=
 =?utf-8?B?YStheklpb1Y5bkJ0cEpSTmdOaG5CakVKTk5PQ05ISVFLRDZSOEJBU08wR2VS?=
 =?utf-8?B?L0E4UnFiVnpxeU5LZFV1N0ZhRHBrSThEcUFhL242R2tvZit1c1Bray9vaVpP?=
 =?utf-8?B?cWwvdW9EMmxaQ1hzMHhiSnlDSUJ2SHZTcFIxc1J1RWlGVlhVbzVFQnY0dE1Y?=
 =?utf-8?B?YUF2Wk9vRy9ROHBpWVpDUmxhVTRVZ213dWU3cmNHcXU1NzNNNGxMWkVHbDVl?=
 =?utf-8?B?UkRmcWJNbnp4YWJCMEtnR1FsWmNxOW9VUk1FaUZ0anphcmQ5T3pwTmV4U1F0?=
 =?utf-8?B?bTZRYVRMSnp3VFhpN0tOeklhdUQvL3BocHJTNlUwVExIL2E0a1RuTVhjcVJv?=
 =?utf-8?B?N2NOUldzVjRRc1F6UDB6YzkyTGI1SUJZbThuanQ0MUI1bkJWTjAvbVlmTlNE?=
 =?utf-8?B?MUxSMCs2RDJnbEdqMjdKRTNMYlM3bHFFQXNHMFRNZStzL3VleUdJL1pjeFZn?=
 =?utf-8?B?SjVVa3VUb2o4MERsYXJ3ZnVjaHordDdQOHRubHhHTmkyUjVidDQzTXlKZURV?=
 =?utf-8?B?eU1jVXVyS3BrR0FHOHJ3SmtpZjJWSG5mdGNjaXhTMitoRGFIejFUV1hmNGRl?=
 =?utf-8?B?TGswZTEzUXpuQUpRWVVTVjVWbmRlS1pkclRDbW16cGw3Q2VUblVVVW83YUdB?=
 =?utf-8?Q?yl74nB7FM0TgzPlq7NoRiFSXV?=
Content-ID: <FF2CDAD86277C84685E66CEDB6FB7883@namprd18.prod.outlook.com>
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: MW3PR18MB3673.namprd18.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 702633e9-d56c-451c-3b0d-08de1c925ace
X-MS-Exchange-CrossTenant-originalarrivaltime: 05 Nov 2025 17:40:04.6950 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 5280104a-472d-4538-9ccf-1e1d0efe8b1b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: j3RfPdJSf1jF6xmAufCentdpNeJ1TMcxCR284QE2SAN0EaUIg5De7P0Wu7UXW05a1Yf5HuTrhbTz33brTTSCYQ==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SJ2PR18MB5586
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
Cc: Andreas Dilger <adilger@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

Pj4+T3ZlcmFsbCwgSSB0aGluayB0aGUgY29uY2VwdCBpcyBpbnRlcmVzdGluZy4gSXQgcmVtaW5k
cyBtZSBvZiBob3cNCj4+PkJjYWNoZWZzIGhhbmRsZSBtdWx0aS1kZXZpY2Ugc3VwcG9ydC4gRWFj
aCBkZXZpY2UgY2FuIGJlDQo+Pj5kZXNpZ25hdGVkIGFzIGhvbGRpbmcgbWV0YWRhdGEgb3IgZGF0
YSByZXBsaWNhcy4gQW5kIHlvdQ0KPj4+Y2FuIGNvbnRyb2wgdGhlIHByb21vdGlvbiBhbmQgbWln
cmF0aW9uIGJldHdlZW4gZGlmZmVyZW50DQo+Pj50YXJnZXRzIChhbGwgbWFuYWdlZCBieSBhIG1p
Z3JhdGlvbiBkYWVtb24pLiBCdXQgdGhpcyBkZXNpZ24gaXMNCj4+PnRvbyBsaW1pdGVkLCBJTUhP
LiBJZiB3ZSdyZSBnb2luZyB0byBhY2NlcHQgdGhlIGFkZGl0aW9uYWwgY29tcGxleGl0eQ0KPj4+
aW4gdGhlIE9TRCwgdGhlIHNvbHV0aW9uIGhhcyB0byBiZSBleHRlbnNpYmxlLiBXaGF0IGlmIEkg
d2FudCB0bw0KPj4+cmVwbGljYXRlIHRvIG11bHRpcGxlIHRhcmdldHM/IFdoYXQgaWYgSSB3YW50
IG1vcmUgdGhhbiB0d28gdGllcnM/DQo+Pj5XaGF0IGlmIEkgd2FudCB0byB0cmFuc3BhcmVudGx5
IG1pZ3JhdGUgZGF0YSBmcm9tIG9uZSBzcGlsbCBkZXZpY2UgdG8NCj4+PmFub3RoZXI/IFdlIGRv
bid0IG5lZWQgdGhpcyBmb3IgdGhlIGluaXRpYWwgaW1wbGVtZW50YXRpb24sIHN1cmUuDQo+Pj5C
dXQgdGhlc2Ugc2VlbSBsaWtlIG5hdHVyYWwgZXh0ZW5zaW9ucy4NCj4NCj5JdOKAmXMgcG9zc2li
bGUgdG8gZXh0ZW5kIHRoZSBkZXNpZ24gdG8gaGF2ZSBtdWx0aXBsZSBzcGlsbCBkZXZpY2VzIGlu
IHRoZSBPU0Q7IHlvdSBjb3VsZCBoYXZlIHR3byBzcGlsbCBkZXZpY2VzIGFuZCBtaXJyb3IgdGhl
bSwgb3IgcmFpZDAgdG8gbWFrZSBhIGxhcmdlciBkZXZpY2UuIEkgZG9u4oCZdCBzZWUgdGhlIGRl
c2lnbiB3b3VsZCBub3QgYWxsb3cgeW91IHRvIGRvIHRoYXQuwqANCg0KSSB0aGluayBJJ20gbW9y
ZSBjb25jZXJuZWQgd2l0aCB0aGUgdGVybWlub2xvZ3kgYW5kIGZyYW1pbmcgb2YgdGhlDQpkZXNp
Z24uIFRoZSBtZW50YWwgbW9kZWwgb2YgdGhlIGRlc2lnbiBpczoNCg0KSGVyZSdzIGFuIE9TRC4g
SXQgY2FuIGdyb3cgb25lIChvciBtb3JlKSBzcGlsbCBkZXZpY2VzIHdoZXJlIHlvdSBjYW4gb2Zm
bG9hZCBibG9jayBkYXRhLg0KDQpCdXQgSSB0aGluayB3ZSBzaG91bGQgdGhpbmsgYWJvdXQgaXQg
bGlrZToNCg0KWW91IGNhbiBoYXZlIGEgc2luZ2xlIGRldmljZSBPU0Qgb3IgYSBtdWx0aS1kZXZp
Y2UgKG9yIHBvb2wpIE9TRC4gRWFjaCBkZXZpY2UNCmluIHRoZSBwb29sIGNhbiBiZSBhc3NpZ25l
ZCBhIHJvbGUgaW4gdGhlIHBvb2wuIFlvdSBkZWZpbmUgYSBwb2xpY3kgZm9yIHdoYXQNCmRldmlj
ZXMgYSB3cml0ZSBoYXMgdG8gbGFuZCBvbiBiZWZvcmUgaXQncyBjb21taXR0ZWQuIFlvdSBkZWZp
bmUgd2hhdCBkZXZpY2VzDQphcmUgdXNlZCBmb3IgY2FjaGluZyByZWFkcy4gWW91IGRlZmluZSBt
aWdyYXRpb24gcG9saWNpZXMuIFlvdSBkZWZpbmUgd2hlcmUgdGhlDQpwb29sIGNvbmZpZ3VyYXRp
b24gYW5kIG1ldGFkYXRhIHdvdWxkIGxpdmUuIGV0Yy4gZXRjLiBUaGUgY29uZmlndXJhdGlvbiB5
b3UgbGF5DQpvdXQgaW4gdGhlIGRlc2lnbiB3b3VsZCBiZSB0aGUgZmlyc3Qgc3VwcG9ydGVkIGNv
bmZpZ3VyYXRpb24gb2YgYSBsYXJnZXINCm11bHRpLWRldmljZSBmZWF0dXJlLg0KDQpJIHRoaW5r
IHRoYXQncyBhIG1vcmUgY29oZXNpdmUgd2F5IG9mIHRoaW5raW5nIGFib3V0IHRoaXMsIElNTy4N
Cg0KPj4+SSB0aGluayB3ZSBuZWVkIHRvIHVzZSBzb21lIGtpbmQgb2YgY29tbW9uIEFQSSBmb3Ig
dGhlDQo+Pj5kaWZmZXJlbnQgZGV2aWNlcy4gRXZlbiBpZiB0aGUgc3BpbGwgZGV2aWNlIGRvZXNu
J3Qgc3VwcG9ydCBhdG9taWMNCj4+PnRyYW5zYWN0aW9ucywgSSBkb24ndCBzZWUgd2h5IHdlIGNv
dWxkbid0IHN0aWxsIHVzZSB0aGUgY29tbW9uIE9TRA0KPj4+QVBJIGFuZCBpbXBsZW1lbnQgdGhl
IG1pZ3JhdGlvbiBkYWVtb24gYXMgYSBzdGFja2luZyBkcml2ZXIgb24tdG9wDQo+Pj5vZiB0aGF0
LiBUaGUgc3BpbGwgZGV2aWNlIE9TRCBkcml2ZXIgY291bGQgYmUgbWFkZSB0byBhZHZlcnRpc2Ug
dGhhdCBpdA0KPj4+ZG9lc24ndCBzdXBwb3J0IGF0b21pYyB0cmFuc2FjdGlvbnMgYW5kIG1heSBu
b3Qgc3VwcG9ydCBFQS4gQnV0IHdlDQo+Pj5nZXQgdGhlIGFkZGVkIGJlbmVmaXQgb2YgYmVpbmcg
YWJsZSB0byB1c2UgZXhpc3RpbmcgT1NEcyB3aXRoIHRoaXMNCj4+PmZlYXR1cmUsIHByZXR0eSBt
dWNoIGZvciBmcmVlLg0KPj4NCj4+QWxzbyBteSBhcmd1bWVudC4gwqBVc2luZyB0aGUgVkZTIGRp
cmVjdGx5IGlzIGNvbnN0cmFpbmluZyAobGFjayBvZg0KPj50cmFuc2FjdGlvbnMpLCBidXQgb2Yg
YmFja2VuZHMgdGhhdCBfY2FuXyBiZSBhIGZ1bGwgT1NEIChvciBhbHJlYWR5DQo+PmhhdmUgYW4g
T1NEIGxpa2UgbGRpc2tmcywgWkZTLCBtZW1mcykgaXQgaXMgYSBkcm9wLWluIHJlcGxhY2VtZW50
Lg0KPj4NCj4+VGhlcmUgaXMgYWxyZWFkeSBhbiBPU0QgQVBJIHRvIHF1ZXJ5IHRoZSBmdW5jdGlv
bmFsaXR5IG9mIHRoZSBiYWNraW5nDQo+PnN0b3JhZ2UsIHNvIGl0IHNob3VsZCBiZSBzdHJhaWdo
dCBmb3J3YXJkIHRvIGFkZCAidHJhbnNhY3Rpb24iLCAieGF0dHIiLA0KPj5hbmQgb3RoZXIgc3Vw
cG9ydGVkIGZlYXR1cmVzIHRvIHRoYXQuDQo+Pg0KPj5JZiB3ZSBjYW4gaW1wbGVtZW50IGEgbm8t
dHJhbnNhY3Rpb24gb3NkLXZmcywgdGhhdCB3b3VsZCBleHBvc2UgYQ0KPj5sb3Qgb2YgZmxleGli
aWxpdHkgZm9yIG90aGVyIHJlYXNvbnMgYXMgd2VsbC4gwqBQb3NzaWJseSB0aGUgb3NkLXZmcyBj
b3VsZA0KPj5pbXBsZW1lbnQgYSBqb3VybmFsIG9yIG90aGVyIGxvZ2dpbmcgbGF5ZXIgaW50ZXJu
YWxseSB0byBtYWtlIHVwIGZvcg0KPj5sYWNrIG9mIHRyYW5zYWN0aW9ucywgd2hldGhlciBpbml0
aWFsbHkgb3IgYXQgYSBsYXRlciBzdGFnZT8NCj4NCj5XaGF0IHdvdWxkIGJlIHRoZSBiZW5lZml0
IG9mIGhhdmluZyBhIGxpbWl0ZWQgT1NEIGluIHRoZSBzdGFjaz8gSSBkb27igJl0IGhhdmUgYSBz
dHJvbmcgb3BpbmlvbiBvZiBub3QgZG9pbmcgaXQsIGJ1dCBJIGp1c3QgZGlkbuKAmXQgc2VlIGFu
eSBiZW5lZml0cyBvZiBkb2luZyBpdC4NCg0KRmxpcHBpbmcgdGhlIHF1ZXN0aW9uIGFyb3VuZDog
d2hhdCdzIHRoZSBiZW5lZml0IG9mIGhhdmluZyBtdWx0aXBsZSBBUElzDQpmb3IgdGFsa2luZyB0
byB1bmRlcmx5aW5nIHN0b3JhZ2U/IFVzaW5nIGEgY29tbW9uIEFQSSBhbGxvd3MgdXMgdG8gdXNl
DQpvc2QtbGRpc2tmcy9vc2QtemZzIGZvciB0aGUgc3BpbGwgZGV2aWNlLiBPciB1c2UgdGhlIG9z
ZC12ZnMgZm9yIE1HUy4gQW5kDQp0aGUgT1NEIEFQSSBpcyBzdGFibGUgYW5kIHdlbGwgZG9jdW1l
bnRlZC4NCg0KX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18K
bHVzdHJlLWRldmVsIG1haWxpbmcgbGlzdApsdXN0cmUtZGV2ZWxAbGlzdHMubHVzdHJlLm9yZwpo
dHRwOi8vbGlzdHMubHVzdHJlLm9yZy9saXN0aW5mby5jZ2kvbHVzdHJlLWRldmVsLWx1c3RyZS5v
cmcK
