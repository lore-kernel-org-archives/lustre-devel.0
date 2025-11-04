Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 870A2CCF9F8
	for <lustre-devel@archiver.kernel.org>; Tue,  4 Nov 2025 01:59:33 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4d0s870RnFz1y22;
	Mon, 03 Nov 2025 17:59:19 -0800 (PST)
Received: from outbound-ip191a.ess.barracuda.com
 (outbound-ip191a.ess.barracuda.com [209.222.82.58])
 (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4d0s7j6L3Sz1wgn
 for <lustre-devel@lists.lustre.org>; Mon, 03 Nov 2025 17:58:57 -0800 (PST)
Received: from PH7PR06CU001.outbound.protection.outlook.com
 (mail-westus3azon11020085.outbound.protection.outlook.com [52.101.201.85]) by
 mx-outbound14-253.us-east-2a.ess.aws.cudaops.com (version=TLSv1.2
 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
 Tue, 04 Nov 2025 01:58:54 +0000
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=H74ZGQweOeApoxnSkAayphUUoAaMlXp8mLfm5/Fm5Rl22gm4+Xc65pHzG9aZoKjLdwsuJjNc5LjJrVctJWoKDJPdILfjYlStluAy4FkSoqCtGBKIaX2xMvHmq1s7HoDSFZ6RHGGUcOVQFzSqbdHFwBNczhT5F+tFmYxWoloJDxsAQ9ndDjSbDYO72N9vtO1ev1tNaAZduc+4nyfCUH9IHJzxh+pLohUO2u2v5FhmqsZfdk+b6xOeEUL4rVCaKW6g382wuG0XPtFXllhPZRCUcr8Klle7RuG8MzAjvyu8TuTKJW2ZW5BSEM44IwucYX9B5OLyEAogtbjL/9MS489JQA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com; 
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=5BcHqWTCTQKXs2glDAZi4pddsM3yftRXMr8T9yoyCMw=;
 b=owJaF/lKPzj16cL/ef2fmbN0qhPw2ZFh4Oh7m6anhYYOxNrF1tB+d51iYStfSEnBqIZk6GbfLQnPF9oEe9YjKNOEKt0sVziZxyJfM29/zTN4E3RUCJKGEyjv6zY4XovIkBx6L9vRy1Vb+xmmK0YfdkCYohfg01pOlsIQud/w8Xkzvf+1jNNDpiP6hTCHi3lSSDV3VmFaTNrxT+Zb2lszdgE7JaFVporfYKNi6XTj3KvqWw17ZcbyqKueBHWmc3915cWVDGKxCuPpX6VdX+DTajurLOvSxHGRmuL+f7CJbBWB75q+CPBpjC1mYA1ega2+LkRKlZ3lFWaOdB1OmhX0yw==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=whamcloud.com; dmarc=pass action=none
 header.from=whamcloud.com; dkim=pass header.d=whamcloud.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=whamcloud.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=5BcHqWTCTQKXs2glDAZi4pddsM3yftRXMr8T9yoyCMw=;
 b=HrxQU1pifI0o3+8Uujc2aWFl9KMnp8BSUJzLF3PyOIZOARlg1sBf28waVdx9IwxZvL7AifE+MrKsU80Kuvw1gvGrr0EnUSKfnvf4HEODZ7US/h/gDrzhq19kfRItPM8C5augWD9wRaaNXIZRmFZfGKo5WK1gDyE42yd9ikOMoks=
Received: from DM3PPF12B913643.namprd19.prod.outlook.com
 (2603:10b6:f:fc00::70b) by CO1PR19MB4856.namprd19.prod.outlook.com
 (2603:10b6:303:db::11) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.9275.15; Tue, 4 Nov
 2025 01:58:52 +0000
Received: from DM3PPF12B913643.namprd19.prod.outlook.com
 ([fe80::1dae:cea7:3265:124e]) by DM3PPF12B913643.namprd19.prod.outlook.com
 ([fe80::1dae:cea7:3265:124e%7]) with mapi id 15.20.9275.015; Tue, 4 Nov 2025
 01:58:52 +0000
To: "jinshanx@google.com" <jinshanx@google.com>
Thread-Topic: [lustre-devel] RFC: Spill device for Lustre OSD
Thread-Index: AQHcTQ1Fb2jVZEEEh0eTrPomJf0YLbThlTCAgAAN0oCAAAMmgIAABRaAgAAXxoA=
Date: Tue, 4 Nov 2025 01:58:51 +0000
Message-ID: <e31f82d56f034cb325ae29a08280122711078a97.camel@whamcloud.com>
References: <e2c69a503e80f3ba59d69f093bc8df519cdd7f66.camel@whamcloud.com>
 <BFDDAAED-BA9A-44DB-BCD0-B3B84E652FE7@gmail.com>
 <c6c016567a02f857303eedb9a4af6b5831c2c818.camel@whamcloud.com>
 <CAEp8vpiZ8iKRbjy8GYKdXFjsycW=a48baOXxUnSP7uE+Xf5cYw@mail.gmail.com>
In-Reply-To: <CAEp8vpiZ8iKRbjy8GYKdXFjsycW=a48baOXxUnSP7uE+Xf5cYw@mail.gmail.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=whamcloud.com;
x-ms-publictraffictype: Email
x-ms-traffictypediagnostic: DM3PPF12B913643:EE_|CO1PR19MB4856:EE_
x-ms-office365-filtering-correlation-id: 34274a68-4f75-41e9-4eaa-08de1b45b41a
x-ms-exchange-senderadcheck: 1
x-ms-exchange-antispam-relay: 0
x-microsoft-antispam: BCL:0; ARA:13230040|376014|366016|1800799024|38070700021;
x-microsoft-antispam-message-info: =?utf-8?B?RTNuU2c2MWozcWZJWTZrYzlkTUowWVQwdGJOU3FVUGRLUkxUT2UvN2wvcUo4?=
 =?utf-8?B?YWlWckQ1VkxuRGU2RmdmVFlWdXdrYWw0QVhKNm9CZXpCL3ZiOGlrblFPZVI1?=
 =?utf-8?B?ZzZ2aTZ1Y2VlVllTdTVtM2RNZTNlNWdjTit5YnNjN2E4Q00rQ0dvUzFWWGVq?=
 =?utf-8?B?ZkFpYnRDVmphUlM0WWVRb3lhcmlPR3FCVzI5TytBWjFGcE5zUzBVTS9mK0d3?=
 =?utf-8?B?UXJkOXNMSDBINnBoNHNBTnBRZU1DTEFOcysyNXdSaml3NTkzNFJneXdkLzhZ?=
 =?utf-8?B?eVY0RTlmSi8wOUp6Z0U5S2hJeUV5QWRIeTRTWElVZFhKSmdpbzdhWlFHSnJQ?=
 =?utf-8?B?bGw1SU9MUzN2WnlySXZJN0hnYzd1MnprNEtWbFUrNTV3MXlqSmhFK3dUMGRk?=
 =?utf-8?B?N2VSUWdhdlc2dkxSUkpEVXpxQXlOWG9uU1cwSXJveDRQQ1czM3ZKaUhBYnFI?=
 =?utf-8?B?MVdoYnZPeWE1dTdOSmNwY1VxT3V5QkFuRXF0VElPRXZKTkJVei9RVGt6Unh2?=
 =?utf-8?B?eTZRNENUY1RGQlZoYVQzUmdIdkVFekIxM2lLdm15OXdNSGRsU2xUM1pLcFNG?=
 =?utf-8?B?bmZtMkVYSHUzaU5qOVBwdmhoMmdsdGUyU1ZvV3hRVXgzRElSeGtLWkFhS1Bp?=
 =?utf-8?B?YnB6dmRBWlpFS29WS0hweUlpWU9yNzNjT2hZRDVscm40MUhNZUQweklWYWx2?=
 =?utf-8?B?K0JTN1NyM0YwRFZMUEgyVUd5Uk5nZ2ZnWUxJMzR3ZEY2aFYycWFvRTlpVWlm?=
 =?utf-8?B?RlNLa2hVYkVSVWhxL3JwSVVmK1hwbTB5UnhOWXRoVkxZZVlXTzJFaGowN1Bn?=
 =?utf-8?B?MTlMVUpkaW5ZcTNOanR1M1VxRFk1T2diVWlXb1FoeUZSNWlZT1JiQmVOUUhI?=
 =?utf-8?B?Y1VmeGJka1BPbEVtdnZjSHphQWV1NE9tQnNsMDU4K0Qydlc1TlBKRzlpQ2tw?=
 =?utf-8?B?NE5IbnlScGsweEZqVTM2dmplNlphMDVKa2JSZjV0M1hXMWZybTVTbUhqT29m?=
 =?utf-8?B?aFdnT0hMUmtSbDdOejNMdmVBbUIwbmU3azRNVUdxZG9oa0ZYUzRWZmRPZVNm?=
 =?utf-8?B?VDg1dEFCVFFQb3NjUkZkRzNhUmwvd1pPcFR4OFpCSzZQWVkvSlhCcGNZS1ZY?=
 =?utf-8?B?b1d1cWc1NTI1QzNuRGJkOW5YekNCdC95WlJjc293aDJkWnN2MENQZ2IwSWVG?=
 =?utf-8?B?R0NLb0lBK1VRVWd0bktSN0RQcGhxajJINDZOVWtyam84dGxyR0s4b0kvbEVj?=
 =?utf-8?B?YWZFZWlRa3pRWnRVZlhESFlKdjdOV2RFbXl3V0tTK05FUW1UeFlha0MzVHB4?=
 =?utf-8?B?RllYZ0R5d0loNzVlRzZ0RTIyeTNPaHBwdE5ZenNKTWRKbkt3aEpKWmMrMDdT?=
 =?utf-8?B?VkJMcUt0YkpyMlgzeWRGaUhseG5CWGxyRzdVclBJbzVtR3JxWkNjS1JXTGh4?=
 =?utf-8?B?Sk5yRkt6TlF0UzhtVWNKV3Vydzg3MkFkSTd5UlFUVTZGQ1lBY0FiTTQ5dDRs?=
 =?utf-8?B?eG42SUFKeFprRXhQUkVhRVhkajJXK0JpVlRuMGlyNWdCcjRnK3FVVlFENlhG?=
 =?utf-8?B?Rmw3VW5aRDlkU3plVGo4ZjRDZ3hneC9WWXJDVE83ZkNSTDJZMVhwY2lSSlkw?=
 =?utf-8?B?b0VwTXVmemZJY0xuakRERDZGUFVLRjlVaGlDWWw2eEY0dk9mVzJ2cGc5bi9F?=
 =?utf-8?B?ZXYraFQ0UjBEeUY0czlqcENCUFpvaDduWXV1ZE82M0lNME9nb0JrakhnN1FG?=
 =?utf-8?B?VFFoNW9Ma2xiS0ZWVXB2MEtTRVRPWnFyb0lmRFY0MkhMekdqN2JJMUVVZFNM?=
 =?utf-8?B?NWFsdmloRUxrbGtSemgvRFpHNGhONlBOajFPd0VVdVV2M3JZOVNJVFpnT2Jp?=
 =?utf-8?B?ZjNrR09JSllQU040WXhvQkE5V3VFdVBPbjFvZjZvdzFObzlmd2d5ekFMWkcv?=
 =?utf-8?B?K21EMGE0ZlFKdTJVbm1iU2RTUXMvTGx6clFFNEo4bkt4S0tqRzhvUGVCRjJC?=
 =?utf-8?B?Unk1NVJkL1F4ajlqdGRoMEtkZDZldkV0TWpLQWdKUFpzNnphTHdFdDlNVnBm?=
 =?utf-8?Q?rnHSPO?=
x-forefront-antispam-report: CIP:255.255.255.255; CTRY:; LANG:en; SCL:1; SRV:;
 IPV:NLI; SFV:NSPM; H:DM3PPF12B913643.namprd19.prod.outlook.com; PTR:; CAT:NONE;
 SFS:(13230040)(376014)(366016)(1800799024)(38070700021); DIR:OUT; SFP:1102; 
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0: =?utf-8?B?cXdWL0l3R0t4bEp3TnhIaW5FZFJnT3hPZUVUMitlQXVWOS8xbkdtSDFDVXR4?=
 =?utf-8?B?c2VwMVJOTWpnSGhIZEVqcFUvSTNwVnFCVHc2RThxcHpweWszWjV1bXlvMHgv?=
 =?utf-8?B?em4wa3dRK0RJcWVRV05rTy9HRFIycXBTOC85TzRlWVpMSDZCb3hlVG1UUmZx?=
 =?utf-8?B?SXZwZ2o0MXhDMVowWjdocnh2YitQK0NKUVBkNm5Ya2pKUGZNaGdqSTlVTjZP?=
 =?utf-8?B?dWJkK0NXMFBZak82ZFdieWUra1VTdSttZmVzZ0diUnpibDI2MXVBSEg3Ui8x?=
 =?utf-8?B?VTM1NlFzS3NDSm53bFRTOGYzT2RHdHlEWlZEc2ZjNEZyNnNTeGF2SnJhRjd5?=
 =?utf-8?B?NSt4aGdIRVRZN25hY1BlYkM1OUkwT0dvelp1OE4raSsrd2lPb1F2dmwxOWRZ?=
 =?utf-8?B?a203UVNXUXMySWNybXp0OVcyMThCWXJaL3hHTDR6bkxaZFo5ZUNiUXBBUlZL?=
 =?utf-8?B?aWwxMExBdEdRa1dQOU1kcllReGNyZDdURDluNkk1endIdmFrZTBsNlMzTkkr?=
 =?utf-8?B?Mk5NUVdmZU5VMVJpcTVkbzFmaDU2RHgzcnRaN1RpUGdIWFNmQ0ZpMDV1Zzly?=
 =?utf-8?B?VmZvV1lsTXNnN2p3N296ZEtDc2pJdWM5QkhiNm92ak9WYTdPVFRzQy9ld1hp?=
 =?utf-8?B?Y3dROFEwWENpRHI4NFpwVlpHeVN0bjJHK2lBLzZaTkVBSTJ6eDFSM0FablJT?=
 =?utf-8?B?eTkrYUloZWxibE1HQ0VCelVEM1k0RDRKR1VWWXV4djIvaUxtenc5Sld5V3ZG?=
 =?utf-8?B?UDlDUjRiUFhObGNXRlZFbW5xYlZaS1JwMUNsM3JIZkNFbk9lb2hQTjZLOGls?=
 =?utf-8?B?TFBYRThEVEJ5OENoS25GenBSTk9WT3NBOXd6eWRzdEVselFLTUZETHhaY05Z?=
 =?utf-8?B?R1FpS0tsS0hrTUNXZ0FZcTU5VDNHMFZteGx0Y3VWNzBLV1pFVkdrenF4WHRs?=
 =?utf-8?B?ekVxWXBMek9SU2NYS0ttVDE1SmFpMWdXR2t3UURaMDBXdXJ1ODRkbUM2bGVo?=
 =?utf-8?B?WlkrMUE4TEh6eU5KelVnWVQwNUF3ZnFwQk1lNHdJT0g2WFFSdXNXWldJbTJF?=
 =?utf-8?B?Uzh6d0w0UGZJbEo0ckhBQzhFM3UvekhPWDBBSjdwbTRKdDFPY005ZVVtZXJZ?=
 =?utf-8?B?SkRZWDFzS2ttczVNaUkzTEhaTjBSQXBzQUJtM3dGTCtTMWwydWZqcmFNRHBK?=
 =?utf-8?B?eWgzT043MXh0UmlwbVh2ZEc0NWRZVkxlZDIzb2pmL0srRTdBZ29YbUtwNTB0?=
 =?utf-8?B?Ty92Y1lXTkJuamdJbDJmWlQvdklMbUpNOVdvbjRieW1CeFBrYUd6Q05NdHhP?=
 =?utf-8?B?M29CVHZveW8ra0NKQlVXcm54TTVpWHNKTnFuTUFNWUw3aG5kcTZZUG9BMnh1?=
 =?utf-8?B?QU40bnlRbWNXTjFZVEQ3czdzUkVtYnRlRFM4QndDeFU3Njd3SnMwa0dBTEhr?=
 =?utf-8?B?aEF6NDI5UDRVN1BNZ29XT1JacmlpKzVmeWJvQk9pWkIyRTBxRUZhcFcreWhh?=
 =?utf-8?B?dHZOY01pZWp4VnZ3MW10TnBmOFcwNTRsWTV5OXUwV0M4T0V3dVE0bHVKdU03?=
 =?utf-8?B?RFlQMVQ1dVJMZ2NjOXdtTGlvdFlCamNJQUlPUkdPWmNqalc5Tktjcnpsajd2?=
 =?utf-8?B?R2w3T1g2dkMycUVNUlJmeEdScW5iMzhBVEMwaWlZT09lbVlSMWFLazc4Mnp1?=
 =?utf-8?B?VnBLSm5RY3BnN0psaDF2Z0ZWM2thRW1VVGpUUXR0VHc5d09DeFpkaXlKUW9L?=
 =?utf-8?B?T0QvYnJkbURoREsxNHRhelBhTlFNR2hiclhoVDJab21KZVhYdXBvZDdQQVdk?=
 =?utf-8?B?QkdxR0xNakkxZjRGTUYwYmxDMjEyNFBpMmhGR25QQzBsNEIxVUxBMVpKOUNO?=
 =?utf-8?B?S0ZvbzlpbE9LNWg5SzIvT0FwTmY5SUVJZTZ6TmlkRWdUV0t6VHZuMk1jMFgw?=
 =?utf-8?B?UWhSTUoyUkVjdFk2ZURyR3NsczhlT2U0dDZjRVUwcDhHNVhFclNrYWk5cGdm?=
 =?utf-8?B?N2hIRWg0ZFlWeUQ1OFR5a3VsdVQraHV6RS9kVk9lZGlBWlQ5MlBNTnl1Y2VP?=
 =?utf-8?B?enREUXF3ZERGWjh3NWl6YXIyNldFRFNqSk9LOUtPM25tSlF4eWMrNlR4SEtq?=
 =?utf-8?Q?Yxv5DOU2uQBiWl5di/kzXpVoq?=
Content-ID: <7773ECAB59629D499CD7CAE2521FA412@namprd19.prod.outlook.com>
MIME-Version: 1.0
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-0: BzZjvHQyVWhSPiCwng+NbZcSR0rIvAJVvO5HVuJZCdekuKT2RtMYUjG9MOy4nuH+itI4TXvBQV+zPxen2K2bIdbOqurMDq4GwVG8LqBO6tyupZj8XNwTB18GvTZ/8pmW2QSMU+f+KTRvXXABc8ej9yabL4CdQmLEm30MBa/BXlmCQ5CvmQV3hhh7RBgOX01LA+XH/0dghcMVkf602WDvOZ8R0JH2rjuDtuWKVbW+zJ0ZrVWOdX2BwUELFEK0sn37KWno8D0Q4sjIzdxFSFJDKyAXfzIk+jXLMid57NXvrr06wjUKPqKRtGio/8kAc9/X+y9I5aCLT1L8TX7FtQWlG1OC5ckpQwvARAS8VCOPo6pxLTtP0mNZxlUWjsX+CxHlz6OemrRAkvpWyQ6M0sheFYzCDb5cbkRusgWUnisGqX1eObDS3TSebJ2GvwZgB3b02Ykd1KO4i6ceOiFNYuomb7EGvOt1Y7YWrZ27wtDkVC2d0hNTNBaQHGWhplrUaSi9zszBclshNdGKowDLT2OvOcYEvzgMhDigjJ+pAO8VguwUNmR38U9w39S1sOpv5ZiA5VNr5FycbKDWnWbESVFAYJ/TJat1jq7EZK3Bmv8BVu6rIn07ktXkxK8eqCIU1tkBGwbuAeL3tw/3njXb2jurtacmJLFim0qQycVQTkvwP0A=
X-OriginatorOrg: whamcloud.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: DM3PPF12B913643.namprd19.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 34274a68-4f75-41e9-4eaa-08de1b45b41a
X-MS-Exchange-CrossTenant-originalarrivaltime: 04 Nov 2025 01:58:52.0892 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 753b6e26-6fd3-43e6-8248-3f1735d59bb4
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: 3jB+B53suTEib1REGpeBlcX0ypfR5zUseNxc5WrbAX54Q/pGVPIPFj0pufparoMF
X-MS-Exchange-Transport-CrossTenantHeadersStamped: CO1PR19MB4856
X-BESS-ID: 1762221534-103837-24145-6926-1
X-BESS-VER: 2019.1_20251103.1605
X-BESS-Apparent-Source-IP: 52.101.201.85
X-BESS-Parts: H4sIAAAAAAACA4uuVkqtKFGyUioBkjpK+cVKVqYm5iZAVgZQMNnUMMnUxCQl0S
 g1OSUl0cTQMtnCKM3SwtzAOC3J1MhUqTYWAN6+uy1BAAAA
X-BESS-Outbound-Spam-Score: 0.10
X-BESS-Outbound-Spam-Report: Code version 3.2,
 rules version 3.2.2.268692 [from 
 cloudscan11-204.us-east-2a.ess.aws.cudaops.com]
 Rule breakdown below
 pts rule name              description
 ---- ---------------------- --------------------------------
 0.10 BSF_SC0_SA085          META: Custom Rule SA085 
 0.00 BSF_BESS_OUTBOUND      META: BESS Outbound 
X-BESS-Outbound-Spam-Status: SCORE=0.10 using account:ESS124931 scores of
 KILL_LEVEL=7.0 tests=BSF_SC0_SA085, BSF_BESS_OUTBOUND
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

T24gTW9uLCAyMDI1LTExLTAzIGF0IDE2OjMzIC0wODAwLCBKaW5zaGFuIFhpb25nIHdyb3RlOg0K
PiA+ID4gPiANCj4gPiA+ID4gSSBhbSBub3Qgc3VyZSBpdCdzIGEgbXVjaCBiZXR0ZXIgaWRlYSB0
aGFuIHRoZSBhbHJlYWR5IGV4aXN0aW5nDQo+ID4gPiA+IEhTTQ0KPiA+ID4gPiBjYXBhYmlsaXRp
ZXMgd2UgaGF2ZSB0aGF0IHdvdWxkIGFsbG93IHlvdSB0byBoYXZlICJvZmZsaW5lIg0KPiA+ID4g
PiBvYmplY3RzDQo+ID4gPiA+IHRoYXQgd291bGQgYmUgcHVsbGVkIGJhY2sgaW4gd2hlbiB1c2Vk
LCBidXQgYXJlIG90aGVyd2lzZSBqdXN0DQo+ID4gPiA+IHZpc2libGUNCj4gPiA+ID4gaW4gdGhl
IG1ldGFkYXRhIG9ubHkuDQo+ID4gPiA+IFRoZSB1bmRlcmx5aW5nIGNhcGFiaWxpdGllcyBhcmUg
cHJldHR5IHJpY2ggZXNwLiBpZiB3ZSBhbHNvDQo+ID4gPiA+IHRha2UNCj4gPiA+ID4gaW50bw0K
PiA+ID4gPiBhY2NvdW50IHRoZSBldmVudHVhbCBXQkMgc3R1ZmYuDQo+ID4gPiANCj4gPiA+IFRo
ZSBtYWpvciBwcm9ibGVtIG9mIGN1cnJlbnQgSFNNIGlzIHRoYXQgaXQgaGFzIHRvIGhhdmUgZGVk
aWNhdGVkDQo+ID4gPiBjbGllbnRzIHRvIG1vdmUgZGF0YS4gQWxzbywgc2Nhbm5pbmcgdGhlIGVu
dGlyZSBMdXN0cmUgZmlsZQ0KPiA+ID4gc3lzdGVtDQo+ID4gDQo+ID4gVGhpcyAoZGVkaWNhdGVk
IGNsaWVudCkgaXMgYW4gaW1wbGVtZW50YXRpb24gZGV0YWlsLiBJdCBjb3VsZCBiZQ0KPiA+IGlt
cHJvdmVkIGluIG1hbnkgd2F5cyBhbmQgdGhlIGVmZm9ydCBzcGVudCBvbiB0aGlzIHdvdWxkIGJy
aW5nDQo+ID4gZ3JlYXQNCj4gPiBiZW5lZml0IHRvIGV2ZXJ5b25lPw0KPiANCj4gDQo+IEFsbW9z
dCBhbGwgZGVzaWducyBhc3N1bWUgc29tZSB1cGZyb250IGltcGxlbWVudGF0aW9uLiBXZSAoYXMg
dGhlDQo+IEx1c3RyZSB0ZWFtKSBjb25zaWRlcmVkIHJ1bm5pbmcgY2xpZW50cyBvbiBPU1Qgbm9k
ZXMsIGJ1dCBjbG91ZCB1c2Vycw0KPiBhcmUgc2Vuc2l0aXZlIGFib3V0IHRoZWlyIGRhdGEgYmVp
bmcgZXhwb3NlZCBlbHNld2hlcmUuDQo+IA0KPiBDYW4geW91IGxpc3QgYSBmZXcgaW1wcm92ZW1l
bnRzIHRoYXQgY29tZSB0byBtaW5kPw0KDQpDbGllbnRzIGJldHdlZW4gc2VydmVyIG5vZGVzIGlz
IHByb2JhYmx5IG9uZSBvZiB0aGUgbW9zdCBvYnZpb3VzDQpjaG9pY2VzIGluZGVlZC4gQ29uc2lk
ZXJpbmcgdGhlIGRhdGEgYWxyZWFkeSByZXNpZGVzIG9uIHRob3NlIG5vZGVzLCBJDQphbSBub3Qg
c3VyZSBJIHVuZGVyc3RhbmQgdGhlIGNvbmNlcm5zIGFib3V0ICJleHBvc2luZyIgZGF0YSB0aGF0
J3MNCmFscmVhZHkgb24gdGhvc2Ugbm9kZXMuIElmIGN1c3RvbWVycyBhcmUgc28gc2Vuc2l0aXZl
LCB3ZSBzdXBwb3J0IGRhdGENCmVuY3J5cHRpb24uDQpXZSBjb3VsZCBhbHNvIGRvIHNvbWUgZGly
ZWN0IHNlcnZlci1zZXJ2ZXIgbWlncmF0aW9uIG9mIHNvbWUgc29ydCB3aGVyZQ0KT1NUcyBleGNo
YW5nZSBkYXRhIHdpdGhvdXQgYnJpbmdpbmcgdXAgcmVhbCBjbGllbnRzIGFuZCBkb2luZyBjb3Bp
ZXMNCmZyb20gdXNlcnNwYWNlLiBUaGF0IG1pZ2h0IGJlIGRlc2lyYWJsZSBmb3Igb3RoZXIgcmVh
c29ucyBmb3IgZnV0dXJlDQpmdW5jdGlvbmFsaXR5IChlLmcuIHZhcmlvdXMgY2FjaGluZyB0aGlu
Z3MgcGVvcGxlIGhhdmUgYmVlbiBsb25nDQplbnZpc2lvbmluZykNCsKgDQo+ID4gDQo+ID4gPiB0
YWtlcyB2ZXJ5IGxvbmcgdGltZSBzbyBpdCByZXNvcnRzIHRvIGRhdGFiYXNlcyBpbiBvcmRlciB0
byBtYWtlDQo+ID4gPiBjb3JyZWN0IGRlY2lzaW9ucyBhYm91dCB3aGljaCBmaWxlIHNob3VsZCBi
ZSByZWxlYXNlZC4gQnkgdGhlDQo+ID4gPiB0aW1lLA0KPiA+ID4gdGhlIHR3byBzeXN0ZW0gd2ls
bCBiZSBvdXQgb2Ygc3luYy4gVGhhdCBtYWtlcyBpdCBwcmFjdGljYWxseQ0KPiA+ID4gdW51c2Fi
bGUuDQo+ID4gDQo+ID4gVGhpcyBhZ2FpbiBpcyBhbiBpbXBsZW1lbnRhdGlvbiBkZXRhaWwsIG5v
dCBldmVuIGhhcmRjb2RlZA0KPiA+IGFueXdoZXJlLg0KPiA+IEhvdyBkbyB5b3UgcGxhbiBmb3Ig
dGhlIE9TVCB0byB0byBrbm93IHdoYXQgc3R1ZmYgaXMgbm90IHVzZWQNCj4gPiB3aXRob3V0DQo+
ID4gcmVzb3J0aW5nIHRvIHNvbWUgZGF0YWJhc2Ugb3Igc2Nhbj8gTm93IHRha2UgdGhpcyBtZXRo
b2QgYW5kIG1ha2UNCj4gPiBpdA0KPiA+IHJlcG9ydCAidXBzdHJlYW0iIHdoZXJlIGN1cnJlbnRs
eSBIU00gaW1wbGVtZW50YXRpb25zIHJlc29ydCB0bw0KPiA+IGRhdGFiYXNlcyBvciBzY2Fucy4N
Cj4gPiANCj4gDQo+IFRoZSBhc3N1bXB0aW9uIGlzIHRoYXQgT1NUIHNpemVzIGFyZSByZWxhdGl2
ZWx5IHNtYWxsLCB1cCB0byAxMDBUQi4NCj4gQWxzbywgc2Nhbm5pbmcgbG9jYWwgZGV2aWNlcyBp
biBrZXJuZWwgc3BhY2VzIGlzIG11Y2ggZmFzdGVyLiBTbyB5ZWFoDQo+IHRoZXJlIGlzIG5vIGRh
dGFiYXNlIGluIHRoZSB3YXkuDQoNCkkgYW0gbm90IHN1cmUgd2h5PyBJbiBnZW5lcmFsIHNtYWxs
IE9TVHMgYXJlIGEgcmVsYXRpdmVseSByYXJlIHRoaW5nDQpiZWNhdXNlIHRvIHJlYWNoIGxhcmdl
IEZTIHNpemVzIHlvdSB3b3VsZCBuZWVkIHRvIG1hbnkgb2YgdGhlbSwgc3BhY2UNCmJhbGFuY2lu
ZyBiZWNvbWVzIGEgY2hvcmUgYW5kIHNvIG9uLiBTbyByZWxhdGl2ZWx5IGZldyBkbyBpdCBmb3Ig
c29tZQ0KZnJpbmdlIHJlYXNvbnMgKGUuZy4gR29vZ2xlKSAuIE1ham9yaXR5IG9mIHBlb3BsZSBw
cmVmZXIgbGFyZ2UgT1NUcy4NCg0KQWxzbyBub3RoaW5nIHN0b3BzIHlvdSBmcm9tIGRvaW5nIGEg
cGVyLU9TVCBzY2FuICh3aGVuIHlvdSBkbyBoYXZlDQpzbWFsbCBPU1RzKSBhbmQgdGhlbiBraWNr
aW5nIHRoZSByZXN1bHRzIHVwIHRvIHRoZSBhY3RpbmcgYWdlbnQgdG8gZG8NCnNvbWV0aGluZyBh
Ym91dCBpdCAob3IgdGhlIG90aGVyIHdheSBhcm91bmQsIHRoZSBoc20gZW5naW5lIGNhbiBhc2sN
Ck9TVHMgb25lIGJ5IG9uZSAocGlja2luZyBsZXNzIGJ1c3kgb25lcyBvciBvbmVzIHRoYXQgaGF2
ZSB0aGUgbGVhc3QNCmZyZWUgc3BhY2UsIG9yIHNvbWUgb3RoZXIgZmFjdG9yKS4gQW5kIHRoZXJl
J3MgYWJzb2x1dGVseSBubyBuZWVkIHRvDQp3YWl0IG91dCB0byBxdWVyeSBhbGwgT1NUcywgeW91
IGNhbiBnZXQgcmVzdWx0cyBmcm9tIG9uZSBhbmQgd29yayBvbg0KdGhlIGRhdGEgZnJvbSBpdCB3
aGlsZSB0aGUgb3RoZXIgT1NUcyBhcmUgc3RpbGwgdGhpbmtpbmcgKG9yIG5vdCwNCnRoZXJlJ3Mg
YWJzb2x1dGVseSBubyByZXF1aXJlbWVudCB0byBnZXQgZnVsbCBmaWxlc3lzdGVtIGRhdGEgYmVm
b3JlDQptYWtpbmcgYW55IGRlY2lzaW9ucykuDQoNCj4gSSBndWVzcyB1c2VycyB3b24ndCBoYXZl
IDFQQiBPU1RzLCB3aWxsIHRoZXk/DQoNClRoZXJlIHByb2JhYmx5IGFyZSBhbHJlYWR5PyBOQVNB
IGhhcyBhIGtub3duIDAuNVAgT1NUIGNvbmZpZ3VyYXRpb246DQpodHRwczovL3d3dy5uYXMubmFz
YS5nb3YvaGVjYy9zdXBwb3J0L2tiL2x1c3RyZS1wcm9ncmVzc2l2ZS1maWxlLWxheW91dC0ocGZs
KS13aXRoLXNzZC1hbmQtaGRkLXBvb2xzXzY4MC5odG1sIzp+OnRleHQ9VGhlJTIwYXZhaWxhYmxl
JTIwU1NEJTIwc3BhY2UlMjBpbiUyMGVhY2glMjBmaWxlc3lzdGVtLGRlY2ltYWwlMjAoZmFyJTIw
cmlnaHQpJTIwbGFiZWxzJTIwb2YlMjBlYWNoJTIwT1NUDQouDQoNCj4gPiBSZXJlYWRpbmcgeW91
ciBwcm9wb3NhbCwgSSBzZWUgdGhhdCB0aGlzIHBhcnRpY3VsYXIgZGV0YWlsIGlzIG5vdA0KPiA+
IGNvdmVyZWQgYW5kIGl0J3MganVzdCBhc3N1bWVkIHRoYXQgImluZnJlcXVlbnRseSBhY2Nlc3Nl
ZCBkYXRhIg0KPiA+IHdvdWxkDQo+ID4gYmUgc29tZWhvdyBrbm93bi4NCj4gDQo+IEkgc2hvdWxk
IGhhdmUgbWVudGlvbmVkIHRoYXQgaW4gdGhlIG1pZ3JhdGlvbiBzZWN0aW9uLiBBbHNvLCB3ZSBu
ZWVkDQo+IHRvIHNsaWdodGx5IHVwZGF0ZSB0aGUgT1NUIHJlYWQgdG8gdXNlIGEgbG9jYWwgdHJh
bnNhY3Rpb24gdG8gdXBkYXRlDQo+IGFuIG9iamVjdCdzIGFjY2VzcyB0aW1lIChhdGltZSkgaWYg
aXQncyBvbGRlciB0aGFuIGEgcHJlZGVmaW5lZA0KPiB0aHJlc2hvbGQsIGZvciBleGFtcGxlLCAx
MCBtaW51dGVzLsKgDQoNClRoaXMgaXMgZ29pbmcgdG8gYmUgZnJhZ2lsZSBpbiB0aGUgZmFjZSBv
ZiB2YXJ5aW5nIGNsb2NrIHRpbWVzIG9uDQpkaWZmZXJlbnQgY2xpZW50cyBwb3RlbnRpYWxseSBu
b3Qgc3luY2VkIHdpdGggdGhlIHNlcnZlcnMuDQpBbHNvIGluIHRoZSBmYWNlIG9mIC1vIG5vYXRp
bWUuDQoNCkJ1dCB5ZXMsIEkgZ3Vlc3MgaXQncyBvbmUgd2F5IHRvIGdldCB0aGlzICJvbiB0aGUg
Y2hlYXAiLCBhbmQgdGhlIG90aGVyDQp0cm91YmxlIEkgZm9yZXNlZSBpcyB5b3UgYXJlIGdvaW5n
IHRvIGhhdmUgYSBiaWFzZWQgc2V0LiBPbmx5IHJlY2VudGx5DQp0b3VjaGVkIG9iamVjdHMgKHNv
IHdpdGggZnJlc2ggYXRpbWUpLCB1bmxlc3MgeW91IHBsYW4gdG8gcmV0YWluIGENCmRhdGFiYXNl
IGFuZCB1cGRhdGUgaXQgZnJvbSBzdWNoIHRyYW5zYWN0aW9uIGZsb3csIHdoaWNoIGNlcnRhaW5s
eSBpcw0KcG9zc2libGUsIGJ1dCBJIGFtIG5vdCBzdXJlIGhvdyBwcmFjdGljYWwgdnMgc29tZSBz
b3J0IG9mIGEgc2Nhbi4NCg0KPiA+ID4gPiBJZiB0aGUgYXJndW1lbnQgaXMgImJ1dCBPU1RzIGtu
b3cgYmVzdCB3aGF0IHN0dWZmIGlzIHVzZWQiDQo+ID4gPiA+ICh3aGljaCBJDQo+ID4gPiA+IGFt
DQo+ID4gPiA+IG5vdCBzdXJlIEkgYnV5LCBhZnRlciBhbGwgYmVmb3JlIHlvdSBjb3VsZCB1c2Ug
c29tZXRoaW5nIG9mZg0KPiA+ID4gPiBPU1RzDQo+ID4gPiA+IHlvdQ0KPiA+ID4gPiBuZWVkIHRv
IG9wZW4gYSBmaWxlIEkgd291bGQgaG9wZSkgZXZlbiB0aGVuIE9TVHMgY291bGQganVzdA0KPiA+
ID4gPiBzaWduYWwNCj4gPiA+ID4gYQ0KPiA+ID4gPiBsaXN0IG9mICJpbmFjdGl2ZSBvYmplY3Rz
IiB0aGF0IHRoZW4gYSBoaWdoZXIgbGV2ZWwgc3lzdGVtDQo+ID4gPiA+IHdvdWxkDQo+ID4gPiA+
IHRha2UNCj4gPiA+ID4gY2FyZSBvZiBieSByZWxvY2F0aWluZyBzb21ld2hlcmUgbW9yZSBzZW5z
aWNhbCBhbmQgY2hhbmdpbmcgdGhlDQo+ID4gPiA+IGxheW91dA0KPiA+ID4gPiB0byBpbmRpY2F0
ZSB0aG9zZSBvYmplY3RzIG5vdyBsaXZlIGVsc2V3aGVyZS4NCj4gPiA+ID4gDQo+ID4gPiA+IFRo
ZSBwbHVzIGhlcmUgaXMgeW91IGRvbid0IG5lZWQgdG8gYXR0YWNoIHRoaXMgIldhcnQiIHRvIGV2
ZXJ5DQo+ID4gPiA+IE9TVA0KPiA+ID4gPiBhbmQNCj4gPiA+ID4gY29uZmlndXJlIGl0IGV2ZXJ5
d2hlcmUgYW5kIHN1Y2gsIGJ1dCByYXRoZXIgaGF2ZSBhIGNlbnRyYWwNCj4gPiA+ID4gbG9jYXRp
b24NCj4gPiA+ID4gdGhhdCBpcyBjZW50cmFsbHkgbWFuYWdlZC4NCj4gPiA+ID4gDQo+ID4gDQo+
ID4gX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18NCj4gPiBs
dXN0cmUtZGV2ZWwgbWFpbGluZyBsaXN0DQo+ID4gbHVzdHJlLWRldmVsQGxpc3RzLmx1c3RyZS5v
cmcNCj4gPiBodHRwOi8vbGlzdHMubHVzdHJlLm9yZy9saXN0aW5mby5jZ2kvbHVzdHJlLWRldmVs
LWx1c3RyZS5vcmcNCj4gPiANCg0KX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX18KbHVzdHJlLWRldmVsIG1haWxpbmcgbGlzdApsdXN0cmUtZGV2ZWxAbGlzdHMu
bHVzdHJlLm9yZwpodHRwOi8vbGlzdHMubHVzdHJlLm9yZy9saXN0aW5mby5jZ2kvbHVzdHJlLWRl
dmVsLWx1c3RyZS5vcmcK
