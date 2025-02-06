Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id BEABFC02194
	for <lustre-devel@archiver.kernel.org>; Thu,  6 Feb 2025 19:08:45 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Ypmpy3gYHz1wl2;
	Thu, 06 Feb 2025 11:08:42 -0800 (PST)
Received: from outbound-ip191a.ess.barracuda.com
 (outbound-ip191a.ess.barracuda.com [209.222.82.58])
 (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Ypmpq6tGBz1wrD
 for <lustre-devel@lists.lustre.org>; Thu, 06 Feb 2025 11:08:35 -0800 (PST)
Received: from NAM02-SN1-obe.outbound.protection.outlook.com
 (mail-sn1nam02lp2047.outbound.protection.outlook.com [104.47.57.47]) by
 mx-outbound47-158.us-east-2c.ess.aws.cudaops.com (version=TLSv1.2
 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
 Thu, 06 Feb 2025 19:08:30 +0000
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=F1cUormL9qxFvBzfVWoHKUYfGP9xO9fbatlWiLAqdSPRoRP8smbgMXlan+q87uUW6gcUsw8+X8MJ8SlHa4wbd/uI8jHoPpt+DLTBAHoOOUeyrtW08ls/Xa6j/I2D1OZPDyec4ceUTyrbWz2WGJmYowy29fmLGCKM2RERej3PkSgn6oCu3Yv0II3L+dPT+lpsYjRbaeh5gXhQFLSKNI+1uAAE8sWOoP1wYHE2iCsp768bU1pp64nHSiaThymM6bp5mKf69Pzv/I1OeO/z1Yxey23GGucHzheuDqRXHziWQ4RU0nH/tPqHGmKV+4cAZTGFlu+5YZctP/TSpuuf03Gnew==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com; 
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=savt2slAby0K+Mal5EZniuYhDHCdvIyBoeLEnqFDRNQ=;
 b=IiZu6hLuOE3FfKmsbxe8EtWToqWCm/eInyQb/utCPI5uG9vhPqvDbgKBysyzK51roSb922pbGTTCEDXIFbMBF6eMtIa3yY0we6ezzRXETSfnuhEWsld6ikcyxcJfcwPzQo6o66068XP+ANR7pBowi/mvMEOnqL0sIS//NAo8JYaBYcg/4vMjFa647BirsLYeoRAsm9d3mWImE72zE6UmdsShAyG1pSl1tGc159+Zb8GXrgJ3bzVilyuxMOdKWc45jZa6L4hp2ynHjFn/NxODtfGbguFNu+BeHFjQTKA/S8uHSBnziwi4IZ18n/XvwwqTlapNWdRq0o00Yj9rfEUj3g==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=whamcloud.com; dmarc=pass action=none
 header.from=whamcloud.com; dkim=pass header.d=whamcloud.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=whamcloud.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=savt2slAby0K+Mal5EZniuYhDHCdvIyBoeLEnqFDRNQ=;
 b=Bm0a3FFnCUKnYU1yX4FDuwqDlEYmH70S93kq0JTd+jZPEPpkW2PBs943cmtwCGfrev1otDzuEeSj6HvOcUVk2YnFe33g0OMiZ86R8IOf0K2PVoz/hRe4bygboEycV6e5/aK1Fn11m5Rec/sv21VFHaOBqbcRq0jJuNGp01vI5ag=
Received: from SN7PR19MB6567.namprd19.prod.outlook.com (2603:10b6:806:26d::11)
 by CH2PR19MB4069.namprd19.prod.outlook.com (2603:10b6:610:9f::18)
 with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.8422.11; Thu, 6 Feb
 2025 19:08:25 +0000
Received: from SN7PR19MB6567.namprd19.prod.outlook.com
 ([fe80::db50:586b:7dda:cf04]) by SN7PR19MB6567.namprd19.prod.outlook.com
 ([fe80::db50:586b:7dda:cf04%3]) with mapi id 15.20.8422.010; Thu, 6 Feb 2025
 19:08:25 +0000
From: Oleg Drokin <green@whamcloud.com>
To: "timday@amazon.com" <timday@amazon.com>, Andreas Dilger <adilger@ddn.com>
Thread-Topic: [lustre-devel] [LSF/MM/BPF TOPIC] [DRAFT] Lustre client
 upstreaming
Thread-Index: AQHbaF06daQEbe3e/kelMir67rT0hbMbs8GAgAAqWwCAAUdfgIABebkAgAf62QCAAH1kAIAMBm2AgAASkoCAAr/pAIAAJnkAgAAH54CAAAPkgIAAAWoAgADH0wCAAKtNgIAAOLaAgALrgwCAAAjiAA==
Date: Thu, 6 Feb 2025 19:08:25 +0000
Message-ID: <bb7cfdc8a1b8c7158420db91de5de31b2bca0519.camel@whamcloud.com>
References: <4243d258f1a38e8539e88a68fb705f05bf18dfb1.camel@whamcloud.com>
 <3B83582B-2D34-4D54-97AF-67E36E93FF74@ddn.com>
 <11E4B1AF-3C2A-4E9A-8847-BA319ED6C301@amazon.com>
In-Reply-To: <11E4B1AF-3C2A-4E9A-8847-BA319ED6C301@amazon.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=whamcloud.com;
x-ms-publictraffictype: Email
x-ms-traffictypediagnostic: SN7PR19MB6567:EE_|CH2PR19MB4069:EE_
x-ms-office365-filtering-correlation-id: e874776a-4ecc-4752-2216-08dd46e1a21b
x-ms-exchange-senderadcheck: 1
x-ms-exchange-antispam-relay: 0
x-microsoft-antispam: BCL:0; ARA:13230040|376014|366016|1800799024|38070700018;
x-microsoft-antispam-message-info: =?utf-8?B?aFNuWWFpMkRhbzFMZG4zYmdhcWRGbVR4VWJJWktjdzJ3WVhEK0t0bmpuUmYz?=
 =?utf-8?B?SStFQXZ0V1JwMncxV2VyenQzOEswL214NnNOdXgzSU9Xb1RUZ2N4eURBK3pP?=
 =?utf-8?B?YktlY1lWeTc0UXE1cytzSGNic3p2U095T09KdDdEQldnOHBhMS96eE9IdUZX?=
 =?utf-8?B?WmptMkZBenk4UFdjTFlPb2pDZlp5VFg3dnAzeTZEOW1MM28yaVUxKzBrSjU2?=
 =?utf-8?B?V3BldllWNnArdHZFdXZYR0ZVNThJNW1pRzYvOFdRbnpRdW9UV0pCTE8zZ0ow?=
 =?utf-8?B?eDhHM2hIc1BxRHUxaEIwVHlpaWFRTWlLcGpVMkR0WEloWUVtcVdWcmp4VU8r?=
 =?utf-8?B?N0Q4VHZoWStEN3ZkN1ZraXpaYU9IK3dYbDVYTjBML2lEMEFManBTUkJpUUZM?=
 =?utf-8?B?b21XSGJDOWtma01lcDBkbFNPWVNPckNxT3BYMXdIUUovMWFlNlp1QStSc1Nr?=
 =?utf-8?B?d093bmFlUmVDY2E5My9QWUNhUFc2MjlDUncyQzVzbzBZRDZkYkNaTEpqc21G?=
 =?utf-8?B?NXkrakl5WTFoZ1lWVWYvbVlkaDBiLzRTbmo1TXZZdHhnMzFpR2gvQlkrUm1X?=
 =?utf-8?B?MG53RkJISG5JV2JtSURRUHkxQWdMRXhpUWduOEJIQ0VJQzIxQWZBdEgzWjVv?=
 =?utf-8?B?OEdvOUtWVjBFWmg3UmpxU24yZWJiejQ3QSszQ0pxSlZveUkwUmhMM3dXSkRS?=
 =?utf-8?B?Y1VGQ2dEZUg4UnZDYVQ2N3FUb2xrZDF6R3FRT0gxV1VlK2J3c0QzTXIwdDc0?=
 =?utf-8?B?RmhHMHdwQWFYNWZoWHZPNDk3RzU2dUNSZXhGallRQXNqZ014emZraVBtdmRy?=
 =?utf-8?B?aFhGWXRBTlhiOHlPWkFVZ2dGMk9DRkFnMmxRbTBsdklNMThyVXhvUUZ4Q3p6?=
 =?utf-8?B?WG5Xa2YwSmRickNFcnNWd1dqUDFtMUZPRGM4bTZtdE9RRzhDbk5KZTJzdG50?=
 =?utf-8?B?M3Z4SlRRck5tand5VzQ3MEVHK2xVanFJVUtybjdsaUVETm1WdGlRUk5vaWZU?=
 =?utf-8?B?Q1R6d2dxSnUwSkJGbjFaaHI4QnJQb2JCZXNESG5GcjFtY2lOZG5wV1BlcmU3?=
 =?utf-8?B?SEUvc20veHNybVVldWY0MnMxYzNGdUFpQ0FHdlV2Y055MkYvRmxwZUFhN0M5?=
 =?utf-8?B?OXFDc1JWTlBGMkhsMUhXd2NNSkRQNkpoVFhtL2gweThzVU0wRzV2bGxpZHJX?=
 =?utf-8?B?Nzg4ek9HaTZDbmtkMkJzcmJQL1p4Y1c5dGlNdHJjTG9GT0U4QzhuWHp1ajhL?=
 =?utf-8?B?Y0NJc3pQU3U2V3licFV1VzFtTXFGc0xrTlV0MDd1cmNkMGp3anArUmROWTly?=
 =?utf-8?B?UzNLKzE3TXprZURBaytSMm0vV1VJaHB5L2dOd3N2ck14a3BLNVJOQURQUFNL?=
 =?utf-8?B?TFVDZmxVblllS1B2Z3J0Z2dLMVVNd2tQbGNYcm5ENWJNcTR3OVFBeE5iaTlV?=
 =?utf-8?B?Z1doQ29nbDdIdXhUNHY2alJaSVUyVmg1anl4L2hKSTk2Y01adVdURlR2aUtC?=
 =?utf-8?B?aGVMSi9ZSGs5N0Z5R1EyR3NZWUVwTUlnb1J1VmtZMWxRUk96MjNnb3d0Ymhr?=
 =?utf-8?B?Rnc1UWdkdGQxcEc4aWQ5cUNRYzRJUHlHSHRyaHRBTm9FM1pYUkNveWd1bXZX?=
 =?utf-8?B?azQxeTlCWG4vVWxZODMwS0grVTNrVStYMHVyVHNlNHJya1JyOS9xdXh2UWs3?=
 =?utf-8?B?Mnp5MWh4RGswcDdqMmk2RTEwTHJXUDV5U0hubHh1NEpCazJNVDZob091Q3FO?=
 =?utf-8?B?TDhFNkNkR1BERXI0Q3FLK1UxekN3ajA0Qk04YkRpMnczV3RlWjlXUWNnMEZU?=
 =?utf-8?B?d2t4TEZzVHZIOStsVkR4N25YMUJFcklMdmpvWjNVK1Z3WWR2TmJEZktNSXds?=
 =?utf-8?B?UW8rWk1PcVhsUWJLbTc4MWUxd2RlZS9XMGpzMFFueVFHWjZuN3hnUS8rcjg4?=
 =?utf-8?Q?6aa/fn7ER2SH4J+rdAJgkOKWwfE7xTro?=
x-forefront-antispam-report: CIP:255.255.255.255; CTRY:; LANG:en; SCL:1; SRV:;
 IPV:NLI; SFV:NSPM; H:SN7PR19MB6567.namprd19.prod.outlook.com; PTR:; CAT:NONE;
 SFS:(13230040)(376014)(366016)(1800799024)(38070700018); DIR:OUT; SFP:1102; 
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0: =?utf-8?B?bHJnQUVwRVRTWlp3SWxkalYwYjZQSGtNenE4KzAvbG1VY2N3QjRsbCtFWlJh?=
 =?utf-8?B?YXhmMHdVZm1WSmpvcmV1T3YxSW5mS0ZUb0lCcVpjZi9pbzBINklPZUZZVEJz?=
 =?utf-8?B?QVd4QldYeWtEeXBTV0NHbWJkM3lSQlNIdCswNWE0NnEraW5uNGVSendvU0xF?=
 =?utf-8?B?eHk2QVVxSmhlQ2dVbzFiVUlXbTBycThKZUJjdFdjYlF1bGFIV2ZBUFZIVW4y?=
 =?utf-8?B?RXFndlJXOHhHeGlqR1k3RzRIR1ErZERJdnEzbUcvUFVNQUE4SXBxbHFVSFE5?=
 =?utf-8?B?eUF0ZkNuNTBFMlJwQnAzREpmTFExZzNGajdBQTBhakNlQTlvQ3dvVUx3WVVa?=
 =?utf-8?B?Skxzb3R4NVlOYzBJcHNoMFJNR3pBL3dUSEI3eklieHg5MlUvKy9uSllnTm5G?=
 =?utf-8?B?L1dmam90M0FoNGhmVEJ0M0t6YTZTTzJMU29IQ29MM0hLTUZmdGVJTVZlWTRz?=
 =?utf-8?B?WG02MW5XTld4WFlXdG15dnMvNnBPeXRQQWRQd3NHREE0Q2gvbnBGQU1CYWF3?=
 =?utf-8?B?azg2clB1YWcrWEg0bVFaUUI1M2luYUVCRk5JMUh0ckFCWXYrUEp4ZGdlRUth?=
 =?utf-8?B?U21YZm5JaEJpS3BiRXlRWkFISS9tTEJmUndkS2QwdEo3cGlhWWhzMk5CRzBt?=
 =?utf-8?B?RjNtc0NPZ1B1SnNpRzB3YUZiR0JrWUtaSjhpUmN6Zm04Uk9vcEVhMFhuYytm?=
 =?utf-8?B?bUtBUFMvaFBXUFNwOU1rNldtZnM4TUVuSGdzcU8vRHhxanpyR2E1eDA2NHox?=
 =?utf-8?B?N1JkeFM0VDliRlFUWXVITmRFcVlTalZtVm9lcEFsUGRPcnJOb29qNUwwdjBs?=
 =?utf-8?B?VUgvRnJJcXp4Nzc5dDV5SFh6VDkwcXdQY25hUERSWS9tRENkSGhtNVRzOTc1?=
 =?utf-8?B?aTluWnI0MXlremFYYlVkdElSUWxZWTBYSTZHWUtvZ0RENGxQdytya01CRFhM?=
 =?utf-8?B?aFhIN2E4MDVBU1JmSE5VMit1TWRob3Ztd2pZcWFRL2orK2ZtZmVOQ3U5c29k?=
 =?utf-8?B?NjcyQWFJeTRRUDF5NFF0elRYR2ZmbnZNYlpVTGYyMDJCTjBtOTVLSk11QU04?=
 =?utf-8?B?UlZQS3Vuc1N6ak1pRm5Cb2U0KytXOS9RVmllbDNOQkFLaFZXUlVTWkV6emFU?=
 =?utf-8?B?dkE0TUYxVEIzOEZGVldvSEJjZDVGVnBpWkpYM1pCaTdUZjlvMVVuL3gzYllU?=
 =?utf-8?B?ME1GelV4djFoejJxRVVNS1N3M1dFQ1BETVpNZlN3cHJVc3E3dytWNlRCVHRT?=
 =?utf-8?B?M0dUa2FwaVc0eVVTMlJoRXRheEZZc3NkVHJ4TlYyWDgrdEJiYmE2TVJpc3NY?=
 =?utf-8?B?WEtVdlBRdFM4ZVBCWEpUZm1Yc1JVaDU3QVFsQXlMTUFQYkpZOVVRN1JQeDJp?=
 =?utf-8?B?S2d0aUp6VWJUeW0yTGg0S1REazNRMW9kazkrVDhsaWlHL3dIUXIvZnJldzdr?=
 =?utf-8?B?VUQrVzhDaFFDaXlvVmJaclRGQ250c1JSL2NGdE9SSGFCbThDQXVBcWpUcEFi?=
 =?utf-8?B?cktkcmNydVdUOEFSTjZnMnFCNWhpbXhjU2RNajBiajJ2b01STjhvczNhYzZ5?=
 =?utf-8?B?SzBUanJJbWpvbDJsSTB4eVlseDFITEorejBmODJLK3FhTStqUzZsMkYrZzhT?=
 =?utf-8?B?VkJ0dDdwSmNHUlJHOHdvQlVTUzhwZWc3eUZnU2pScUQ3a1BjWVdEZ0JOekxP?=
 =?utf-8?B?N1B5UTNsS0tKeTV0SGlLR3BmN3IzT1VBRDBpdTRDNVd2RDNVZzFwNlIzWUN0?=
 =?utf-8?B?Qms3bVdrS1ZUcUJua2V0dUQyajFlb1dUdGk3S2YvMEFNZ2ZZSE44SWdpV3lr?=
 =?utf-8?B?VkZ5MnRXd3RHZ25wOU1rWFFkeGN1UXF5eS9BTE8vdURCV3RRVEJVd1R2ZnR3?=
 =?utf-8?B?aEFnOFNFUUxVdUJiOHNHbjlJZ0I4clVFWVB1ejMwNFJscHVndjdYYmtFc2w1?=
 =?utf-8?B?dE1KSHZSK0JhbnBqS3VlYWZGcjR4SGczODNnZlFydkJOUVNoSVl4MlM5WmhZ?=
 =?utf-8?B?VXdZekYwTldtU1pXQjhzSFN4eDRpY3RQRVluS2VWZWVlcHcrM1RYbnp2aDA1?=
 =?utf-8?B?TXUrZEM5NmQwVCtLMCtIQWFoTEdhSEk1dUJyZGt2d1FkN3ZZbER5dnJyL1FF?=
 =?utf-8?Q?9791VyRqpzkfatvYdi0419RKK?=
Content-ID: <FB932C9ABE100741ACCA058529963E61@namprd19.prod.outlook.com>
MIME-Version: 1.0
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-0: BHxjEIrPmI3A86z45h1aj8ySRPxAdhgFPfCkf0Lmj6mvmDr+Cj4pRL4pGWqOEqDL1cmAuR+YZRTHOcsdzJPSOHUhd6PbNI57YjVsIudXT6KNs/L4RjuOEU4Mav8dK4b1iF1kd4FUAyId/r9i4eGsvbsfg9i1HIBRhevASEEstVkMhEYb58zmhgFnpNaiFSsVVhjuBHXkiErqOwHHxC4EWo4u69+iumWnXoxstqwQ3Oa4B/uooL8Bb1YwDGowYPqhjUOkD607p7v4/SholUGlMHxEJoarb0o72idiNPTfXXL2GfQYyeMJOHuo3w6QCEDMGbVTnbiFV3GEra4d5GCVnXh8b9fYISlMagg2BE3L9B3LeGfjFACOKP5Hh7XkdfwH8CgjgJt3tQ7sSOCTO/lsHHGvmSOYCe0PVDtH+wbzmQeA5LDoJ//BERHKNK3RD1Y2bkO+vwqrUQfEfXN+7N62qsDPU9lj4kkmHceSCMs9IN16bK6etVt3lgarauX2H1p19hct/J9UINZ7H3cr0GUyqMfbBZKKgmCIItpAdnQJqftbrxYFwyP2Xn6sFks4dlpxeFGdRJVS+NqzHWrxRkf5qwXcFQkt5mFtywNs57g3XlWMf0baiiH5ERfxc4uLTE1byc9SynnzwyME2Zb1tVl4tW8HDLDJ1N77a4k6m+MvDK0=
X-OriginatorOrg: whamcloud.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: SN7PR19MB6567.namprd19.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: e874776a-4ecc-4752-2216-08dd46e1a21b
X-MS-Exchange-CrossTenant-originalarrivaltime: 06 Feb 2025 19:08:25.7446 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 753b6e26-6fd3-43e6-8248-3f1735d59bb4
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: ULsjPMN1on6n+fiT2POr8NWpFeTPSc3GDi/eTemBDXb0FsKtKVwmOoq24gRnnuMe
X-MS-Exchange-Transport-CrossTenantHeadersStamped: CH2PR19MB4069
X-BESS-ID: 1738868909-112190-7501-10443-1
X-BESS-VER: 2019.1_20250205.2128
X-BESS-Apparent-Source-IP: 104.47.57.47
X-BESS-Parts: H4sIAAAAAAACA4uuVkqtKFGyUioBkjpK+cVKVpZmxkBGBlAs1SItzdQ80cTS0s
 TE3DTNOMnUIMnY0tQoKdHQwDA1yUSpNhYAt6Gh7EAAAAA=
X-BESS-Outbound-Spam-Score: 0.00
X-BESS-Outbound-Spam-Report: Code version 3.2,
 rules version 3.2.2.262336 [from 
 cloudscan20-112.us-east-2b.ess.aws.cudaops.com]
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
Cc: "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

On Thu, 2025-02-06 at 18:36 +0000, Day, Timothy wrote:
> > To better cover the skew between different VMs running different
> > subtests, we could change the test-framework code to run the
> > subtests in different order (either starting at a random offset, or
> > in random order).
> > 
> > This would also expose some hidden assumptions and dependencies in
> > the subtests themselves, so that would need to be fixed to avoid
> > false test failures, but the main goal of the boilpot testing is
> > finding crashes/deadlocks, so if a few tests fail because of minor
> > test issues I don't think that is a blocker.
> > 
> > 
> > Cheers, Andreas
> 
> We could also limit each VM to run a subset of the sanity tests. Then
> we could cap the length of the longest run test. I have some
> scripting
> magic already to divide up the subtests between VMs.

That probably means you need more VMs to cover everything good enough
(the process is probabilistic as it is)
_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
