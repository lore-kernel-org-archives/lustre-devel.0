Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 710C6C02187
	for <lustre-devel@archiver.kernel.org>; Sun, 19 Jan 2025 20:46:58 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4YblrL55NDz1xNw;
	Sun, 19 Jan 2025 12:46:42 -0800 (PST)
Received: from outbound-ip168b.ess.barracuda.com
 (outbound-ip168b.ess.barracuda.com [209.222.82.102])
 (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Yblqv4LrHz1wb1
 for <lustre-devel@lists.lustre.org>; Sun, 19 Jan 2025 12:46:19 -0800 (PST)
Received: from NAM02-DM3-obe.outbound.protection.outlook.com
 (mail-dm3nam02lp2047.outbound.protection.outlook.com [104.47.56.47]) by
 mx-outbound45-213.us-east-2c.ess.aws.cudaops.com (version=TLSv1.2
 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
 Sun, 19 Jan 2025 20:46:16 +0000
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=gIG5V1ujMLAQlSAms3BVNtvu7WnGzVBaZ7pkJFhAUodXqoornuMBqJvzDF4yhVajTSq5Um1si4tdHmojMKxyTsvhWgBXlKWGa6i9FE7zoQltSFuMdUqlqnZv2LHV3Og/tkxPJAJDx46ts4ka4563tgkbMdk3YtQ2xwEeQEc7TbPMNMRm2Vl+wT/r+4gYw9TmNJILYIcUPP0gVoIoJDQHuMrud+UPoRITJnNPsaXcQJ95k3QkGw+3/cy1jtv0j7MT48G2+dlmh3LIJo8eT68tnmD1Qi24xk9AlYSC75fKD1TjObTmaWdnAVuZNolrZVCo8IAz8OhEYWRLnk7AT4aqOQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com; 
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=qxLnISrqz57IoJx9+fBTa5VeurIXupw8qQ93rx+TSvc=;
 b=Hmtzof6rXifV047iimr5a4x9ViqjK7V4PSbo/+PAPquSxFGq3e6y7ZWquTMqjaLJX2q23VcCNfH0n+mxIxrj+a5hRhKHrdFcvfj8BxZ8TN+J2N0sYcbBKEr36NxUp4fay0LpIJWybB0HaPH1i8zcIg3TmOLpZ+3I6CM8YX4Wiomynu2tGPs+sp6A/wfCKs4SEJP3ZP9DSKdtvRZIinhB3+WrlD0GEG95d6zi/+V7WyKs5dJlIqKkJu7So1VYs0Ky6mIC3NPgfov0kSKsRwSKaQJ+L8lRpENzwCV/gAbdxBUxbRML/wKNkceil48YCjqOh8wJF8bLqnidIr4Zzm2CZw==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=whamcloud.com; dmarc=pass action=none
 header.from=whamcloud.com; dkim=pass header.d=whamcloud.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=whamcloud.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=qxLnISrqz57IoJx9+fBTa5VeurIXupw8qQ93rx+TSvc=;
 b=Er3MsjfReiE23VNnDnIeMx4oHduQFrc78VE/s/YwZWDCWOLhVvfeuazimVzjcSfqmGr7FUriOZb0gB5wPWSwv9XQfGKcMypor+XOrTf5IduALrG43Q2R0H7YsL/O5PaVK8646a++TWHVl7i5esvw/73H1q1b4+gn21BLc4Ya9yU=
Received: from SN7PR19MB6567.namprd19.prod.outlook.com (2603:10b6:806:26d::11)
 by CO1PR19MB5047.namprd19.prod.outlook.com (2603:10b6:303:d4::22)
 with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.8356.20; Sun, 19 Jan
 2025 20:46:13 +0000
Received: from SN7PR19MB6567.namprd19.prod.outlook.com
 ([fe80::db50:586b:7dda:cf04]) by SN7PR19MB6567.namprd19.prod.outlook.com
 ([fe80::db50:586b:7dda:cf04%6]) with mapi id 15.20.8356.017; Sun, 19 Jan 2025
 20:46:12 +0000
From: Oleg Drokin <green@whamcloud.com>
To: "timday@amazon.com" <timday@amazon.com>, "neilb@suse.de" <neilb@suse.de>
CC: "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>
Thread-Topic: [lustre-devel] [LSF/MM/BPF TOPIC] [DRAFT] Lustre client
 upstreaming
Thread-Index: AQHbaF06daQEbe3e/kelMir67rT0hbMbs8GAgAAqWwCAATXlAIABgZyA
Date: Sun, 19 Jan 2025 20:46:12 +0000
Message-ID: <e5dea863089af0d377beb7f5d9c5d735d192bd94.camel@whamcloud.com>
References: <3139EEF5-91BF-4F8E-A112-1D66455AE3D2@amazon.com>
 <173716111777.22054.8452560203667698532@noble.neil.brown.name>
 <785a407c987a57ddf6bbfbed05230981af66cd26.camel@whamcloud.com>
 <A2A33C79-3467-4E93-952D-9646346E0349@amazon.com>
In-Reply-To: <A2A33C79-3467-4E93-952D-9646346E0349@amazon.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=whamcloud.com;
x-ms-publictraffictype: Email
x-ms-traffictypediagnostic: SN7PR19MB6567:EE_|CO1PR19MB5047:EE_
x-ms-office365-filtering-correlation-id: f0df5ebf-6f93-4b33-0bb7-08dd38ca4fbd
x-ms-exchange-senderadcheck: 1
x-ms-exchange-antispam-relay: 0
x-microsoft-antispam: BCL:0; ARA:13230040|366016|1800799024|376014|38070700018;
x-microsoft-antispam-message-info: =?utf-8?B?d3MraC9lbkhtYXNnYzZkNDZOWlhrQzV6NVcwazQyTU01bXpSVnZqbTFHbEdx?=
 =?utf-8?B?OWhKRlJlcVlUR0MrWTc2WmI0Q1RwaGRtd2FRMlNRaUF2TnY3YjI3bXByYVAv?=
 =?utf-8?B?V1FlZzMvZEhmalFsTEpsM0wyb3VpOW9CVTJJS0gxUHNueFNRZ0tnNjU5Y0Fo?=
 =?utf-8?B?eUZFc2NVL2RaMEFIK3Z3UThKVkZZaVBDYTU2OVBoQ0xERzZmZDVHOUZmRmZo?=
 =?utf-8?B?Q3dpRW9YbkxXZURXampiRkVmdzdJTUwvZXZwNkNBaUQrSkRtcEdtMWxEWUJO?=
 =?utf-8?B?RktHU3JhK05hR1huVEJmbldUVWRGODRqQkdXbGcwU3ZnV21FenlEV0VmckJK?=
 =?utf-8?B?bWdINHRDVk83eVl1SXZhendGSW5SRGdxL3ZrdEM3ekJraWhVOGQ3UjhnKzdN?=
 =?utf-8?B?cGMxM3pMYjNRTHVtdjIxZDRTZHpuWmR4RUtkbkZPR0pjU2FYcWJ3YmtNdk03?=
 =?utf-8?B?MEF0MmRJdzZwbzg1UTB6YVg0Z0RnWWszbjl4bXhDUzFDL0lVaFF6RlpZUmtI?=
 =?utf-8?B?c1liSFozNUJyZHhCQ0E3WmdJbGVKQVd0VFo5UGREUUluL2NlVlNTQk1LQWx4?=
 =?utf-8?B?dUNhSVNpUjNKeWZJVFVDdTQ2MDFOTjNVS2FEQmoxbElyelBUeDRMcno2TXAw?=
 =?utf-8?B?MnNQS0xPTUw4ZFFuZWduU05lTnkvcDU1dU9jb2t0N1E2aHltL0owM0NyYzJa?=
 =?utf-8?B?empmai9QV1FjUFFNSUtFVFFGeW5nTE85cmxWNEEybGp4WTlQb2dhb1IycnMr?=
 =?utf-8?B?azd6TC9XYUhjakJ4OHZTSGJhKzFJbFJUVk8zRlErYU85aVR6QXo1Q3d4SDhy?=
 =?utf-8?B?UlhTT2Qvb2s0OG1odTlmZEFoMVpjVzV6UHQvS0xTamdFcUpNb2szMThjR3RU?=
 =?utf-8?B?NHhUQXI3KzVoenZwaUFJT051SzczMUVEbHBpZGg5OHdNY3JKb2kzSGxETHBZ?=
 =?utf-8?B?Sm5nKzFKK1dFM0hUSWNQN1Fjd3JsNGFUQVRSQklBU3ZsUEhqVEF6SXl0Y1ZE?=
 =?utf-8?B?bWlybWZzb0J1UTQyc0s4N0syaEV0UmJDeFFpKysrbjNHRWRWTjRDY0JwZEh3?=
 =?utf-8?B?Y2I3dEE0blJoUTNyKzhDaDBDL0YyVmg2bCtwV2dQc0I0a1EzN0pWV1FqVmEz?=
 =?utf-8?B?Wm9xVU4yRU9QbXQySEFjTWJCMzZDWTFlQkQxUHZ5eXlUMElFSk5kWGY1dlpj?=
 =?utf-8?B?eXFRcnZHYWxoczJLd3JvcGJrZDJDaFlRZnJxRDJabW9xSCs0SnhxeU1ubkxM?=
 =?utf-8?B?OHRERy91M2o2c3V3UW53ckhyNzc4bTJrK0JBOHhGMEVHSUIwS0RTNTcwaW9q?=
 =?utf-8?B?NTh0ZjYwOUZYemZKNnJPYUdlMHphZGVaeGdTYS9ET2ZYUXJQMm55ZzdaMkZV?=
 =?utf-8?B?V1htenAzNFJvVWNIYTloUVhOdnFuM1hxVVdYYzViQU8rYytxaTR4eVQyQWpJ?=
 =?utf-8?B?QnV1SkNPaVdnSkorWnJSUGFQN3Bxd0dXWGl5aE5RbDRqN3BCbjVzNkF5TjRV?=
 =?utf-8?B?a0srRGJldWUzMEx3RXczZ29Xa1lzcU5Ha1RGcWxDWm5KRmo4cVBqNkJ5QlJm?=
 =?utf-8?B?blpxcWljQXd5T3ZLZHViTW9GNmJOQ2dzNDFDTVc3RWFCM1U2S3A3VldKSFU0?=
 =?utf-8?B?WFhnWC9GeE1UR0NNUjZZMFRzV2dMMi9ndkNMRTlNYWZUaktkUkRucGJZU293?=
 =?utf-8?B?ak5ES1hoWE9EMm5xdW1sZVZRWEl0YUJjbWZWKzVtcGNyNUZMMDVCUW1CcjVj?=
 =?utf-8?B?SUZPZElKVjMwVU84ZVRvSGFSRFN6YjFwNDJaU0JOUUNuT3JGemdwa2dieWtL?=
 =?utf-8?B?bFhvcVJ0M2dLOTY0SlUwc21SbVZhVmtvNGJaN3RITmpXenlKNHFrY1B0aDFN?=
 =?utf-8?B?K1ZxNzgrVy93WHJEZzdqd0pqRTZWZjBZeUZGRmpvR0VmOHZWZ0x0RDI1SjZB?=
 =?utf-8?Q?FP3XkLvvDPkHZdQ9aMd/+NqC1Y/kQWc4?=
x-forefront-antispam-report: CIP:255.255.255.255; CTRY:; LANG:en; SCL:1; SRV:;
 IPV:NLI; SFV:NSPM; H:SN7PR19MB6567.namprd19.prod.outlook.com; PTR:; CAT:NONE;
 SFS:(13230040)(366016)(1800799024)(376014)(38070700018); DIR:OUT; SFP:1102; 
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0: =?utf-8?B?dllSRlVGd2lhR1g1RTZGSFkvYzJwN1NPVU1XTW5XQVNwaG1mOEI1TFpiVjQr?=
 =?utf-8?B?TWdpTHgvOFRpMVRuU0xRdjZ4bkFCRFBOWVlnR2ZsVEtmdXd1WTNGQjRzaFp2?=
 =?utf-8?B?WDJWZXFXN2dDWkxVeGFQSEVjUldtRlJQZjk0M3BuaTlYQ2hkeXBvelNHdnlV?=
 =?utf-8?B?cXhDUGNQaUFvV3FFamlkNTlsdWFFeit0Wm9aUUxWd2h3cVNRYlNiY2FZQVFx?=
 =?utf-8?B?WG90Wlp2VFZ1bDM2QWx5a0VYU1FDV2Z1WmF1a2NuK0Yyd3k4NGNmcVFZTnYz?=
 =?utf-8?B?WXFjK0ZOTzBZRFV3SnUzVHkzamM5VnhnTmhFQndzUGtmajdSU0hXNlZMZVpQ?=
 =?utf-8?B?Qk5CaFZic3E3TUpYQ1BhR1VjdmoyenN3ZUZ3WGRnODh3Y05nRC9ESnFsM2o5?=
 =?utf-8?B?SFdVSytYRGVNbWoweCsyZHdOQ1NJVGd4dmVsRFVJNStBWTJrSi9IMnQ3RXBT?=
 =?utf-8?B?emVUUEhrZkNYQUZGZVN1YitEVnE3c2tlRlhGRUkwdmkrZXBETGhjSWJ5clZU?=
 =?utf-8?B?blVPL0s0NGxiOElVano1a2hlT3NJWHUvSnpzeGlpSDYzZ1VGUFJ5Y1BETlJl?=
 =?utf-8?B?cUdkUEZhcGs1VTVxblpvU3NVd3U5UUdQazkzem5LSzNjSUFTeTNHNzR5TDNS?=
 =?utf-8?B?QUx1RTVyQ3d1akhXaUV1TWNJa1RkUDdLdkM2NW9xWjQveUY3UGlMWWZDckpi?=
 =?utf-8?B?YVcyNDA1T2g4S1lNZm80N2dlajc2NDJTSnFvQm1aRHQyeWJmZS85V0ZsazFH?=
 =?utf-8?B?cDhPVm56WVRkNUhKdjJhN29iRDFWb2p3UjdvN1l4TmhURmVTb08zYWZuNnI5?=
 =?utf-8?B?Y0t4Q0M1d2lZc3VxT3ArMkpJVURXSmVVRGdoY0FnUlBuTlgwYUNIMW4yaXdK?=
 =?utf-8?B?ZlZYdk5tcWYwMjR0S0EzVkNkaFVLbndNMGFzNVRCajNlM3ROVVBxRGs4YkY3?=
 =?utf-8?B?TkdKR0RnUVVFZy9HMlJFdmp5bGdkeXZUVW1rbm9xaDVNSjdsL0JtS3htb3Uv?=
 =?utf-8?B?dDlVN3ZwdHFaY1JSVjlkdzk4OWVVMHNwNkVIZ3FvV1JpbnFuTG5kR1pwYWNO?=
 =?utf-8?B?YUl2czFNMHlxUDltK3ZpNHgyV1RjL3RSK3JkVlZSbWJ5VHRWVWJLOWs4VUNR?=
 =?utf-8?B?YmtXd1dFMElqMGFsUzhlWVN5M0hibjRwVXhEaGxyU1lDdmJHZDRIZXZnUzhr?=
 =?utf-8?B?OU5NWW9taUV6UFFVZjRTenlNQnFoNXcyVjBtVTEyc2RSTFptemNHWUVuUExP?=
 =?utf-8?B?Z1orcW5wcWY1L296SE5MaVB4YVNOVklxcy84bUs2bDFWUUVidlF0dC9zZXht?=
 =?utf-8?B?RC9yaVV5SzZDNHU1UDZuZHlsN25yd2dxSzBURVk2dUppY2VYelJEVlNKSFV5?=
 =?utf-8?B?MGEvb2dTNjlBdUhiTlBXUXQ4cjNyRE9vN1lJK3d5WUUwNWlObXc4ajhnQjZl?=
 =?utf-8?B?bzg1WExtMFVhTVM2Ykc4SlVYQ2FiZHFPM0hqZ3dLb3lKTXhDemp4TCtETG5W?=
 =?utf-8?B?aFVibzl6WG9jYytQd3VKTTB2a05xd25iT1VWNENwcHgzR0NSRzJsemRxanh1?=
 =?utf-8?B?bFJpRXJpdTEvdjhXdDIvTDJmelpLT0FycnJ4bjhpOHZ2aWR2TW1QRURsVE1Q?=
 =?utf-8?B?TWRpYXZiemJzK051bnhLTmtmME9SWDQyOHB4QlZVZlZJdWF3eGRDWVJsZVZ6?=
 =?utf-8?B?T2t3RGFSR0tTcWtZZ1V0MXBLdmdMejk0ZEFGbXNWanh6bEQ0b1RxbkJSWFE4?=
 =?utf-8?B?RTlOeGZydm5VRnVrYlNvbHNXaGF0MFUvdVhjWXB0ZkJleFZGbmRtQjVMckZK?=
 =?utf-8?B?cU4xUlVOTnJISTRDUUFNMHhaeWJ1dU5uZCtoK0xzMmRNRFF3bnpFa2xzQ25I?=
 =?utf-8?B?aGRUeDVRZmZHRHYwRmxSZU5jNWdaL2prbVY1blVrM1ZlRkU4bEc3RXNwdFlU?=
 =?utf-8?B?WkxoeDRBTXRKNzlxSjJJeXc4SzNJVGFKTXpnYWw1bDZyNXh0eHYyYjB4eXVE?=
 =?utf-8?B?NTN4TUVPcEFhSDJCeGdxMmRHK205SGJEWHY4VlhlT045dkhmamR6ODRpQVU4?=
 =?utf-8?B?bnBNMEZhMDFXM2ltbnphUkQwbTFzYkk1QmlnRUNiVzRzMjFVRm9WR1JLV2l5?=
 =?utf-8?Q?U2TNXC7zvUmGBVQEXlbNV1eUv?=
Content-ID: <885D37B90D498F49ABA0FD7F88A18D8C@namprd19.prod.outlook.com>
MIME-Version: 1.0
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-0: ZwfjOjqng2BKIq/oYtz/t9hLlXj/CMsebHhV/znP7lb9jJgvcXsCx4aYdOCOEt8nmqylnYYyzcauFxI5oiANEV5G9GHsMxig+JGc1Varkp4KsOMSKnYgzzMwy5K5/CB5SQLl6hAeSlutgko4Sw7i+R20fsm7nk7itG/YYN0s0d7rO0jEWLnupqchGVUaCfAMsdRuTAfkBFm1OkS0sd0K3e2WMHY7tqHohq+cL9mndfUVFnqWi5GlcSwH94Xw+qQYYgsR+ZItu+UnaeR1hljYpcaef8RPkgT+5y1LMt2YYja0ITy2IW8hbagPDe4BLhFoHNza2tu8lm7IdIKs9AOkO0PLpUe3rpZPMRrfptCtgS84sy1moogpAiV1gNI2aaU5fReSzIKbu+B/yCc2IPecDrZL/G9LpBgvi6GGtWBRWvzEhjYlpif/02MDcof8w8Cbfguwk7hU46rWn/NXXaAjnnVikOlC6kNViWjEqhseE2HhhIfYMGNQTodedjjuWAt8yY66p6kMKwa1SjgVr/lAFTL+pL2bV6R/10CtbTKiWKMqQW/c00xS85WeszVl28wZvDMzo8pXGaZgxlFC1cujsNryFrwIZ30BTqL/P6m/BiyYYAWzsPKmfMb0HXaZ3INKc5su1rt1wFWRn+uevURJ8TlPMQ6aWXb4TPtHDkqXcpU=
X-OriginatorOrg: whamcloud.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: SN7PR19MB6567.namprd19.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: f0df5ebf-6f93-4b33-0bb7-08dd38ca4fbd
X-MS-Exchange-CrossTenant-originalarrivaltime: 19 Jan 2025 20:46:12.8712 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 753b6e26-6fd3-43e6-8248-3f1735d59bb4
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: dxj4U89HuIWATS0C3R9qGRajhk0Gquwp2HdXs30OHQibWqvKIN7UFWCNOPx8Wd6x
X-MS-Exchange-Transport-CrossTenantHeadersStamped: CO1PR19MB5047
X-BESS-ID: 1737319575-111733-14959-189704-1
X-BESS-VER: 2019.1_20250117.1903
X-BESS-Apparent-Source-IP: 104.47.56.47
X-BESS-Parts: H4sIAAAAAAACA4uuVkqtKFGyUioBkjpK+cVKVmZmRqZAVgZQ0CQlzdA8MdE8zc
 DMxNjAwtDEPNk41cg02TDFMsUsOdVUqTYWABf9gnlBAAAA
X-BESS-Outbound-Spam-Score: 0.00
X-BESS-Outbound-Spam-Report: Code version 3.2,
 rules version 3.2.2.261926 [from 
 cloudscan17-209.us-east-2b.ess.aws.cudaops.com]
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

T24gU2F0LCAyMDI1LTAxLTE4IGF0IDIxOjQ2ICswMDAwLCBEYXksIFRpbW90aHkgd3JvdGU6DQo+
IA0KPiANCj4gPiBPbiAxLzE3LzI1LCAxMDoxNyBQTSwgIk9sZWcgRHJva2luIg0KPiA+IDxncmVl
bkB3aGFtY2xvdWQuY29twqA8bWFpbHRvOmdyZWVuQHdoYW1jbG91ZC5jb20+PiB3cm90ZToNCj4g
PiA+IE9uIFNhdCwgMjAyNS0wMS0xOCBhdCAxMTo0NSArMTEwMCwgTmVpbEJyb3duIHdyb3RlOg0K
PiA+ID4gV2UgbmVlZCB0byBkZW1vbnN0cmF0ZSBhIHByb2Nlc3MgZm9yLCBhbmQgY29tbWl0bWVu
dCB0bywgbW92aW5nDQo+ID4gPiBhd2F5DQo+ID4gPiBmcm9tIHRoZSBkdWFsLXRyZWUgbW9kZWwu
IFdlIG5lZWQgcGF0Y2hlcyB0byB0aG9zZSBwYXJ0cyBvZg0KPiA+ID4gTHVzdHJlDQo+ID4gPiB0
aGF0IGFyZSB1cHN0cmVhbSB0byBsYW5kIGluIHVwc3RyZWFtIGZpcnN0IChtb3N0bHkpLg0KPiA+
IA0KPiA+IA0KPiA+IEkgdGhpbmsgdGhpcyBpcyBub3QgdmVyeSByZWFsaXN0aWMuDQo+ID4gTGFy
Z2UgY2h1bmsgKDEwMCU/KSBvZiB1c2VycyBkbyBub3QgcnVuIG5vdCBvbmx5IHRoZSBsYXRlc3Qg
a2VybmVsDQo+ID4gcmVsZWFzZSwgdGhleSBkb24ndCBydW4gdGhlIGxhdGVzdCBMVFMgZWl0aGVy
Lg0KPiA+IA0KPiA+IA0KPiA+IFdoZW4gd2Ugd2VyZSBpbiBzdGFnaW5nIGxhc3QgdGhpcyBtYW5p
ZmVzdGVkIGluIHJhbmRvbSBwYXRjaGVzDQo+ID4gYmVpbmcNCj4gPiBsYW5kZWQgYW5kIGJyZWFr
aW5nIHRoZSBjbGllbnQgY29tcGxldGVseSBhbmQgbm9ib2R5IG5vdGljaW5nIGZvcg0KPiA+IG1v
bnRocy4NCj4gPiANCj4gPiANCj4gPiBPZiBjb3Vyc2Ugc29tZSBhdXRvbWF0aWMgaW5mcmFzdHJ1
Y3R1cmUgY291bGQgYmUgYnVpbHQgdXAgdG8gbWFrZQ0KPiA+IGl0DQo+ID4gc29tZXdoYXQgYmV0
dGVyLCBidXQgaXQgZG9lcyBub3QgcmVtb3ZlIHRoZSBwcm9ibGVtIG9mICJub2JvZHkNCj4gPiB3
b3VsZA0KPiA+IHJ1biB0aGlzIG1haW5saW5lIHRyZWUiLCBJIGFtIGFmcmFpZC4NCj4gDQo+IEkg
dGhpbmsgdGhlcmUncyBhIGRlY2VudCBjaHVuayBvZiB1c2VycyBvbiBuZXdlciBrZXJuZWxzLiBV
YnVudHUNCj4gMjIvMjQgaXMNCj4gb24gKGEgYml0IHBhc3QgbGF0ZXN0KSBMVFMgNi44IGtlcm5l
bCBbMV0sIEFMMjAyMyBpcyBvbiBwcmV2aW91cyBMVFMNCj4gNi4xIFsyXSwgYW5kDQo+IHdvcmtp
bmcgb24gdXBjb21pbmcgTFRTIDYuMTIgWzNdLg0KDQpXZWxsLCBJIG1vc3RseSBtZWFuIGluIGNv
bnRleHQgb2YgTHVzdHJlIGNsaWVudCB1c2UgYW5kIHN1cmUgdGhlcmUncw0Kc29tZSA2LjggTFRT
IGluIHVzZSBvbiB0aG9zZSB1YnVudHUgY2xpZW50cywgdGhvdWdoIEkgY2Fubm90IGFzc2VzcyB0
aGUNCnJlYWwgbnVtYmVycywgbWFqb3JpdHkgb2YgcmVwb3J0cyBJIHNlZSBhcmUgc3RpbGwgb24g
NS54IGV2ZW4gb24NClVidW50dS4NCg0KPiBXaGVuIGEgcGF0Y2ggbGFuZHMgaW4gbHVzdHJlLXJl
bGVhc2UvbWFzdGVyLCBpdCBjb3VsZCBiZSBhcm91bmQgMSAtDQo+IDEuNSB5ZWFycw0KPiBiZWZv
cmUgaXQgbGFuZHMgaW4gYSBwcm9wZXIgTHVzdHJlIHJlbGVhc2UuIEF0IHRoYXQgcG9pbnQsIGl0
IG1pZ2h0DQo+IHNlZSByZWFsDQo+IHByb2R1Y3Rpb24gdXNhZ2UuDQoNCldlbGwsIG5vdCByZWFs
bHkuDQpJIGd1ZXNzIGl0IG1pZ2h0IG5vdCBiZSBzZWVuIGFzIGVhc2lseSBmcm9tIHRoZSBvdXRz
aWRlLCBidXQgImx1c3RyZS0NCnJlbGVhc2UvbWFzdGVyIiBwYXRjaGVzIGFyZSBiYWNrcG9ydHMg
ZnJvbSAidHJ1ZSBwcm9kdWN0aW9uIiBicmFuY2hlcy4NCnRoZSBudW1iZXIgYXBwcm9hY2hlcyAx
MDAlIGZvciBmZWF0dXJlcywgYnV0IGV2ZW4gYSBzaXphYmxlIG51bWJlciBvZg0KZml4ZXMgYXJl
IGJhY2twb3J0cy4NCkluIHBhcnRpY3VsYXIgYW55dGhpbmcgdGhhdCBjb21lcyBmcm9tIEhQRSBh
cmUgYmFja3BvcnRzLCB0aGV5IHJ1bg0KdGhlaXIgcHJvZHVjdGlvbiBzdHVmZiwgc29tZXRpbWVz
IGhpdCBwcm9ibGVtcywgY3JlYXRlIGZpeGVzLCBhbmQgdGhlDQpldmVudHVhbGx5IGRldGVybWlu
ZSB0aGF0IHRoZSBwcm9ibGVtIGlzIHByZXNlbnQgaW4gbWFzdGVyIGFzIHdlbGwgKG9yDQpzb21l
dGltZXMgYjJfeCBicmFuY2hlcykgYW5kIHN1Ym1pdCB0aGVpciBwb3J0cyB0aGVyZS4NCg0KVGhl
IGFjdHVhbCBsYWcgYmV0d2VlbiBmZWF0dXJlcyBiZWluZyBkZXZlbG9wZWQgYW5kIHRoZW4gZ2V0
dGluZyBpbnRvDQp0aGUgbWFzdGVyIGJyYW5jaCBjb3VsZCBiZSByYXRoZXIgbG9uZyB0b28uDQoN
Cj4gU28gSSB0aGluayBpdCdzIG1vc3RseSBhIG1hdHRlciBvZiBjb252aW5jaW5nIHBlb3BsZSB0
byB1c2UgYW4NCj4gdXBzdHJlYW0NCj4gY2xpZW50LiBJIGRvbid0IHRoaW5rIHBlb3BsZSB3YW50
ZWQgdG8gdXNlIHRoZSBzdGFnaW5nIGNsaWVudCBiZWNhdXNlDQo+IGl0DQo+IGRpZG4ndCB3b3Jr
IHdlbGwgYW5kIHdhc24ndCBzdGFibGUuIEFuZCB2ZW5kb3JzIGRvbid0IHdhbnQgdG8gd29yayBv
bg0KPiBzb21ldGhpbmcgdGhhdCBubyBvbmUgdXNlcy4gSXQgdGhlIGNsaWVudCBpcyAiZ29vZCBl
bm91Z2giIGFuZCBwZW9wbGUNCj4gYXJlIGNvbmZpZGVudCBpdCdsbCBjb250aW51ZSB0byBiZSB1
cGRhdGVkLCBJIHRoaW5rIHRoZXkgd2lsbCB1c2UgaXQuDQo+IFRoZQ0KPiBzdGFnaW5nIGNsaWVu
dCB3YXMgbmVpdGhlciBvZiB0aG9zZSB0aGluZ3MuDQoNCkkgYWdyZWUgb25jZSB5b3UgY29udmlu
Y2UgcGVvcGxlIChib3RoIHVzZXJzIGFuZCBkZXZlbG9wZXJzKSB0byB1c2UgdGhlDQp1cHN0cmVh
bSBjbGllbnQgdGhpbmdzIHdpbGwgbW92ZSBpbiB0aGlzIGRlc2lyYWJsZSBkaXJlY3Rpb24sIGJ1
dCByaWdodA0Kbm93IEkgZG9uJ3Qga25vdyBob3cgdG8gY29udmluY2UgdGhlbS4NCm9uIFJIRUwg
KGFuZCBkZXJpdmF0aXZlcykgZnJvbnQgdGhlIHRpbWUgbGFnIGlzIGh1Z2UgaW4gcGFydGljdWxh
ci4NCg0KPiA+IEl0IGRvZXMgbm90IGhlcCB0aGF0IHRoZXJlIGFyZSB3aGF0IDM/IDQ/IHRyZWVz
LCBub3QgImR1YWwtdHJlZSIgYnkNCj4gPiBhbnkNCj4gPiBzdHJldGNoIG9mIGltYWdpbmF0aW9u
Lg0KPiA+IA0KPiA+IA0KPiA+IFRoZXJlJ3MgREROL3doYW1jbG91ZCAodGhhdCdzIHJlYWxseSB0
d28gdHJlZXMpLCB0aGVyZSdzIEhQRSwgTExOTA0KPiA+IGtlZXBzIHRoZWlyIGZvcmsgc3RpbGwg
SSB0aGluayAodGhvdWdodCBpdCdzIG1vc3RseSBiYWNrcG9ydHM/KS4NCj4gPiBUaGVyZQ0KPiA+
IGFyZSBsaWtlbHkgb3RoZXJzIEkgYW0gbGVzcyBleHBvc2VkIHRvLg0KPiANCj4gSSB0aGluayBt
b3N0IG5vbi1jb21tdW5pdHkgTHVzdHJlIHJlbGVhc2UgYXJlIGRlcml2ZWQgZnJvbSB0aGUNCj4g
Y29tbXVuaXR5IHJlbGVhc2UgYW5kIHBlcmlvZGljYWxseSByZWJhc2VkLiBJIHRoaW5rIEFXUywN
Cj4gV2hhbWNsb3VkLCBMTE5MLCBNaWNyb3NvZnQgd291bGQgZmFsbCBpbnRvIHRoYXQgYnVja2V0
LiBBbmQgSQ0KPiBkb3VidCBERE4gYW5kIEhQRSBzaWduaWZpY2FudGx5IGRpdmVyZ2UgZnJvbSBj
b21tdW5pdHkgTHVzdHJlLiBCdXQNCj4gaWYgc29tZW9uZSBpcyBkaXZlcmdpbmcgc2lnbmlmaWNh
bnRseSBmcm9tIGNvbW11bml0eSBMdXN0cmUsIEkgdGhpbmsNCj4gdGhleSBhcmUgb3B0aW5nIGlu
dG8gYSBzaWduaWZpY2FudCBtYWludGVuYW5jZSBidXJkZW4gcmVnYXJkbGVzcyBvZg0KPiB3aGF0
IHdlIGRvIHdpdGggbHVzdHJlLXJlbGVhc2UvbWFzdGVyLg0KDQpCb3RoIERETiBhbmQgSFBFIHNp
Z25pZmljYW50bHkgZGl2ZXJnZSB3aXRoIG5ldyBmZWF0dXJlcyBhbmQgc3VjaC4NClRoZXJlJ3Mg
YWxzbyBhIChub3cgbW9zdGx5IGRvcm1hbnQpIEZ1aml0c3UgIkZFRlMiIGZvcmsgdGhhdCB0aGV5
IGdvdA0KdGlyZWQgb2YgbWFpbnRhaW5pbmcgYW5kIHRyaWVkIHRvIGZvbGQgYmFjayBpbiwgYnV0
IGNvdWxkIG5vdC4gKGFsc28NCkNyYXkncyBzZWN1cmUgZGF0YSBhcHBsaWFuY2UgdGhhdCBzZWVt
cyB0byBoYXZlIG1ldCBhIHNpbWlsYXIgZmF0ZToNCmh0dHBzOi8vZ2l0aHViLmNvbS9DcmF5L2x1
c3RyZS1zZGEgKQ0KDQpZZXMsIG1haW50ZW5hbmNlIGJ1cmRlbiBjb25zaWRlcmF0aW9uIGlzIGFs
d2F5cyB0aGVyZSBvZiBjb3Vyc2UsIHNvDQp0aGVyZSdzIHNvbWUgY29vcmRpbmF0aW9uIG5vd2Fk
YXlzIChsaWtlIHJlc2VydmluZyBmZWF0dXJlIGZsYWdzIGFoZWFkDQpvZiB0aW1lIGFuZCBzdWNo
KSwgYnV0IGl0J3Mgbm90IG91dHNpZGUgb2YgcmVhbG0gb2YgcG9zc2liaWxpdHkgdGhhdCBpZg0K
d2hhdCdzIHBlcmNlaXZlZCBhcyAidGlwIG9mIHRoZSBjb21tdW5pdHkgdHJlZSIgYmVjb21lcyBp
bmNvbnZlbmllbnQsDQppdCdsbCBiZSBkcm9wcGVkLg0KSW4gZmFjdCBhIHNpbWlsYXIgdGhpbmcg
aGFwcGVuZWQgdG8gdGhlIHN0YWdpbmcgbHVzdHJlIGluIHRoZSBwYXN0IEkNCmd1ZXNzLCBvbmx5
IGJlZm9yZSBpdCBldmVuIGJlY2FtZSB0aGUgcGVyY2VpdmVkIHRpcCAoZm9yIGEgdmFyaWV0eSBv
Zg0KcmVhc29ucykuDQoNCg0KPiA+IFN1cmUsIG9ubHkgb25lIG9mIHRob3NlIHRyZWVzIGlzIGNv
bnNpZGVyZWQgImNvbW11bml0eSBMdXN0cmUiLCBidXQNCj4gPiBpZg0KPiA+IGl0IHdpbGwgZGV0
YWNoIHRvbyBtdWNoIGZyb20gd2hhdCBtYWpvcml0eSBvZiBkZXZlbG9wZXJzIHJlYWxseQ0KPiA+
IHJ1bnMNCj4gPiBhbmQgZ2V0cyBwYWlkIHRvIGRvIC0gdGhlICJjb21tdW5pdHkgTHVzdHJlIiBj
b250cmlidXRpb25zIHByb2JhYmx5DQo+ID4gd291bGQgZGltaW5pc2ggZ3JlYXRseSwgSSBhbSBh
ZnJhaWQuDQo+IA0KPiBBcyBsb25nIGFzIHRoZSBjb21tdW5pdHkgTHVzdHJlIGRldmVsb3BtZW50
IHByb2Nlc3MgaXMgc2FuZSwgSSB0aGluaw0KPiBtb3N0IG9yZ2FuaXphdGlvbnMgd2lsbCBvcHQg
dG8gY29udGludWUgZGVyaXZpbmcgdGhlaXIgcmVsZWFzZXMgZnJvbQ0KPiBpdCBhbmQgb3B0IHRv
IGNvbnRpbnVlIGNvbnRyaWJ1dGluZyByZWxlYXNlcyB1cHN0cmVhbS4gV2UganVzdCBuZWVkDQo+
IHRvIG1ha2Ugc3VyZSB3ZSBnZXQgYnV5LWluIGZyb20gdGhlIHBlb3BsZSBjb250cmlidXRpbmcg
dG8gTHVzdHJlLg0KDQpXZWxsLCB0aGVyZSdzIGFub3RoZXIgaGFsZiBvZiBpdCwgdGhlIGtlcm5l
bCBzaWRlLiBQcmV2aW91cyBydW4gaW4gd2l0aA0Kb3RoZXIga2VybmVsIG1haW50YWluZXJzIGhh
ZCBsZWZ0IGEgYml0IG9mIGEgc291ciB0YXN0ZSBpbiBwZW9wbGUncw0KbW91dGhzLg0KT2YgY291
cnNlIHRoZXkgaGF2ZSB0aGVpciBvd24gcmVhc29ucyB0byBkaWN0YXRlIHdoYXRldmVyIHRoZXkg
d2FudCB0bw0KbmV3Y29tZXJzIChBbmQgYWxsIGNvbWluZyBwYXRjaGVzKSwgYnV0IG9uIHRoZSBv
dGhlciBoYW5kIEx1c3RyZSBpcyBhDQptYXR1cmUgcHJvZHVjdCB0aGF0IGNvdWxkIG5vdCBqdXN0
IGRyb3AgZXZlcnl0aGluZyBhbmQgcmV3cml0ZQ0Kc2lnbmlmaWNhbnQgY2h1bmtzIG9mIHRoZSBj
b2RlIChzZXZlcmFsIHRpbWVzIGF0IHRoYXQpIG8gYmV0dGVyIGFsaWduDQp3aXRoIHRoZSBldmVy
IGNoYW5nZWQgZGVtYW5kcyAoYmNhY2hlZnMgSSB0aGluayB3YXMgYSBoaWdobHkgcGFyYWRlZA0K
YXJvdW5kIGV4YW1wbGUgb2YgdGhhdCwgYW5kIHRoZXkgY291bGQgYWNjb21tb2RhdGUgdGhvc2Ug
b2Z0ZW4NCmNvbmZsaWN0aW5nIGRlbWFuZHMgYmVjYXVzZSBub3QgbWFueSBkZXBsb3ltZW50cyBp
biB0aGUgd2lsZCkuDQpJIGRvbid0IGtub3cgaG93IHBvc3NpYmxlIGlzIGl0IHRvIG92ZXJjb21l
LiBLZXJuZWwgbWFpbnRhaW5lcnMgZG9uJ3QNCnJlYWxseSBjYXJlIGFib3V0IEx1c3RyZSAoYW5k
IHJpZ2h0ZnVsbHkgc28sIHdlIGFyZSBidXQgYSBibGlwIHRvIHRoZW0pDQphbmQgdGhlbiB3ZSBh
bHNvIGhhdmUgb3VyIG93biBwcmlvcml0aWVzLg0KDQpBbmQgd2hpbGUgZm9yIEx1c3RyZSBkZXZl
bG9wZXJzIHRoZXJlJ3MgYSBiZW5lZml0IG9mICJ0aGUgYWRqdXN0aW5nIHRvDQpuZXcgaW50ZXJm
YWNlcyBjb21lcyBmb3IgZnJlZSIsIHRoZXJlJ3Mgbm8gYmVuZWZpdCB0byB0aGUga2VybmVsDQpt
YWludGFpbmVycywgc28gdGhleSBkb24ndCBoYXZlIG11Y2ggaW5jZW50aXZlLg0KKGFuZCBhZ2Fp
biB3ZSBzYXcgdGhpcyBpbiB0aGUgcHJldmlvdXMgYXR0ZW1wdCkNCg0KQW5kIGV2ZW4gaW1hZ2lu
ZSBieSBzb21lIG1hZ2ljIHRoZSBhY3R1YWwgaW5jbHVzaW9uIGFuZCBhbGwgdGhlDQpyZWxldmFu
dCByZXdvcmsgaGFwcGVuZWQuIE5vdyBIUEUgb3IgREROIHdhbnRzIHRvIGFkZCBhIG5ldyBmZWF0
dXJlLA0KdGhleSBpbXBsZW1lbnQgaXQgYW5kIHRoZW4gc3VibWl0IGFuZCBhIG1ldCB3aXRoIHRo
ZSB1c3VhbCAibm93IHJld29yaw0KaXQgaW4gdGhlc2Ugb3RoZXIgd2F5cyIgZGVtYW5kcy4NCk9m
IGNvdXJzZSBhZ2FpbiBmcm9tIHRoZSBrZXJuZWwgbWFpbnRhaW5lcnMgcGVyc3BlY3RpdmUgdGhp
cyBpcw0KZW50aXJlbHkgcmVhc29uYWJsZSBhbmQgaXQncyBub3QgdGhlaXIgcHJvYmxlbSB0aGUg
ZGV2ZWxvcG1lbnQgcHJvY2Vzcw0KaXMgd3JvbmcgYW5kIGJhY2t3YXJkcyBhbmQgaW5zdGVhZCBv
ZiBkZXZlbG9waW5nIGV2ZXJ5dGhpbmcgaW4gdGhlIG9wZW4NCm9uIHRoZSBwdWJsaWMgYnJhbmNo
IHdpdGggaW5wdXQgZnJvbSBhbGwgcGFydGllcyBpbnRlcmVzdGVkIHRoZXJlJ3MNCnRoaXMgY2xv
c2VkIGRldmVsb3BtZW50IGdvaW5nIG9uLiBCdXQgZ29vZCBsdWNrIGNvbnZpbmNpbmcgcmVzcGVj
dGl2ZQ0KbWFuYWdlbWVudCBvZiB0aG9zZSBjb21wYW5pZXMgdG8gYWdyZWUuDQoNCg0KX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KbHVzdHJlLWRldmVsIG1h
aWxpbmcgbGlzdApsdXN0cmUtZGV2ZWxAbGlzdHMubHVzdHJlLm9yZwpodHRwOi8vbGlzdHMubHVz
dHJlLm9yZy9saXN0aW5mby5jZ2kvbHVzdHJlLWRldmVsLWx1c3RyZS5vcmcK
