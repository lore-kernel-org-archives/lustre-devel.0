Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 14AACC02188
	for <lustre-devel@archiver.kernel.org>; Mon, 20 Jan 2025 05:37:49 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Ybzd548njz1xS1;
	Sun, 19 Jan 2025 21:37:45 -0800 (PST)
Received: from outbound-ip168b.ess.barracuda.com
 (outbound-ip168b.ess.barracuda.com [209.222.82.102])
 (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Ybzcv71Gvz1xFL
 for <lustre-devel@lists.lustre.org>; Sun, 19 Jan 2025 21:37:35 -0800 (PST)
Received: from NAM10-BN7-obe.outbound.protection.outlook.com
 (mail-bn7nam10lp2048.outbound.protection.outlook.com [104.47.70.48]) by
 mx-outbound-ea22-15.us-east-2b.ess.aws.cudaops.com (version=TLSv1.2
 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
 Mon, 20 Jan 2025 05:37:32 +0000
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=qwWHNtAj7qvHkOg+z6Mq8XHyrRngA7aSzqhB2F/jNkRU7tvi9LKwA4HLsGI08Jep83eztlynBDha5EPEJYBqFOAp2+t/B08bwJ7hx/yfJhhfszDNrxblDeSurQkYCNunh46BMEqeM+2Z1PxIkYJ9NYg9weWO02+V+r+nzx22VomJMhzMFTmDmWHDgrP9/22hdqUbVcOeXXBMhkG60+/CMeIWW4YbWntSHmL5MeIH8ekyRLARGg5oKFF/VLXuaDCfjUlnMzqQe8RUNGg7ml+UH6mb4JD2OkB82icQndVdhpzODyfT2PyaqF8zE4uEyxw6oH0TQCbfIqNvAGp6oMs5Vw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com; 
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=7AZHq8eQMmYDEw8W3nIohKKLw3iqEhNMzJFLVyLIeUI=;
 b=BMf2B/msKItweZXjus4lKZA+T4bDM8mK8i7BunU0/1kO9NXMjNfwHJVnFPOTzz/phoUA0RqDTwYWC64ugJPpJt+IbmG5W+8xHCz9f/wPD7vDQ+Jh7nbfDmbvFQB9UR0UdMWbZTDXoVUI2/ewWpn9XoqhW4ZI9InYK2y7cIpxVx22Rm+IkmfHXha8qzO9/7q9fUHS7Q12JkWHntaO2pGKyfOdP89qVkaf2NlQIrHdikegIeCVDK9M0TbJZv/pRi62+YwvbP/ZbDPFW4jE1vZGlWq7w/vuM+49QPnVHMdb80ktG6BJg2oicvpEEeZq6xqukaVUSb+dw65f8MMAyRUlRg==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=whamcloud.com; dmarc=pass action=none
 header.from=whamcloud.com; dkim=pass header.d=whamcloud.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=whamcloud.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=7AZHq8eQMmYDEw8W3nIohKKLw3iqEhNMzJFLVyLIeUI=;
 b=RTpcsr22W00YQwz1o4tl/GnuN+7cTxCajW/MTkAmeuka5FgrRJBTlS6m//0Ai5ltlpH2z4g5D8cVuhrmXNrZ6fEilDStuoyXy9HwKtbl+r1eAc+frP+ORy19dDINX+vJFBQmRKzYqwP7kLXERzsfF8Mq+lKVj9bmkO9DLXmP1SQ=
Received: from SN7PR19MB6567.namprd19.prod.outlook.com (2603:10b6:806:26d::11)
 by SJ2PR19MB8096.namprd19.prod.outlook.com (2603:10b6:a03:53a::5)
 with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.8356.20; Mon, 20 Jan
 2025 05:37:28 +0000
Received: from SN7PR19MB6567.namprd19.prod.outlook.com
 ([fe80::db50:586b:7dda:cf04]) by SN7PR19MB6567.namprd19.prod.outlook.com
 ([fe80::db50:586b:7dda:cf04%6]) with mapi id 15.20.8356.017; Mon, 20 Jan 2025
 05:37:28 +0000
From: Oleg Drokin <green@whamcloud.com>
To: "timday@amazon.com" <timday@amazon.com>, "neilb@suse.de" <neilb@suse.de>
CC: "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>
Thread-Topic: [lustre-devel] [LSF/MM/BPF TOPIC] [DRAFT] Lustre client
 upstreaming
Thread-Index: AQHbaF06daQEbe3e/kelMir67rT0hbMbs8GAgAAqWwCAATXlAIABgZyAgACD4ICAABCQgA==
Date: Mon, 20 Jan 2025 05:37:28 +0000
Message-ID: <ae77142069ee7e302800a8b67f7d694364bc659f.camel@whamcloud.com>
References: <3139EEF5-91BF-4F8E-A112-1D66455AE3D2@amazon.com>
 <173716111777.22054.8452560203667698532@noble.neil.brown.name>
 <785a407c987a57ddf6bbfbed05230981af66cd26.camel@whamcloud.com>
 <A2A33C79-3467-4E93-952D-9646346E0349@amazon.com>
 <e5dea863089af0d377beb7f5d9c5d735d192bd94.camel@whamcloud.com>
 <F0CBB79F-37D7-4786-979D-70B34EEACA81@amazon.com>
In-Reply-To: <F0CBB79F-37D7-4786-979D-70B34EEACA81@amazon.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=whamcloud.com;
x-ms-publictraffictype: Email
x-ms-traffictypediagnostic: SN7PR19MB6567:EE_|SJ2PR19MB8096:EE_
x-ms-office365-filtering-correlation-id: eb002e36-132f-4903-3c98-08dd391486f0
x-ms-exchange-senderadcheck: 1
x-ms-exchange-antispam-relay: 0
x-microsoft-antispam: BCL:0;
 ARA:13230040|1800799024|376014|366016|13003099007|38070700018; 
x-microsoft-antispam-message-info: =?utf-8?B?M0ptUkV3Z1NiQWw2UThYek9NelZGYzRGTGRmQXFJZk8vcGk2dTdmNzEveGlH?=
 =?utf-8?B?VHdHZWg5QUQ4aGFTRXFWWnF2Q09zeFRFWStJbCtqTXhCUE1QUzJjUFhxWVZ0?=
 =?utf-8?B?NnpWOXlTRTE0dVVVbEYvTmFLNVpLSk91MVhPZCtmejBXa0pwcU1FTU15cnE4?=
 =?utf-8?B?Tzg0amwvWFppTU5yZHFqSlAySFMrMXJ4R0VGdVZhRVJ6MXRTbkVLK2tESkFN?=
 =?utf-8?B?OTgrK1duNENaRGZZSlNVRm4zTnVVWWtOK0IvNVQ0cUQzYXNOcWpsMkRpcXpo?=
 =?utf-8?B?TmlmcGFFSWxBaGY1UUp6dWl2ekI4TlZIT04rYmRIOVFFOEtkeXd2cWh0MnBj?=
 =?utf-8?B?L2lKeHd1N0Z2LzhEN1N5V3oyZ0I4MjdYYlRYV1haNGJla05HSDFnaTNPMFUz?=
 =?utf-8?B?WjN5RFVWUHRqSHVFNWlxQjAxNkR5QkdwQk9TWDhjY29iYmRBS3dvazNlYXlB?=
 =?utf-8?B?c25oMzQyQ0w1TE9meEFFWFlrZ1FYYUVBcWlGbDFzdEl0K3pVbFBna2tvOThU?=
 =?utf-8?B?elVSKysyZnZHdVVwaDA5RkRvU09WMWpkcTlPT1pmMDhFY0VOUUY3R292RFFL?=
 =?utf-8?B?WTVJU251OG96UDVkSGlBZTRtVnhXb1V2OVRtc0N4c3J2RmVWaUg3QmRFSE1E?=
 =?utf-8?B?ZnBWRGh4Q3NEZDNiTC9YZUJYUSt5T1FjQnVSWjVLVHM4RTMvT2hLQjNPVE92?=
 =?utf-8?B?VU02cEhJR08wcU93RTdrY0JKbnU5K25zMjFxNDg4RFVDb2FENjJ4RDRnWkw4?=
 =?utf-8?B?WW5KaThuckxHWnZ0c1I5bUlVcG1YODU5R2RwYUo0RThERTF1K2l2ZkVTN2dJ?=
 =?utf-8?B?a2ZzRzlWTnczQkl2UnNoSXVLUllURXEyT05MK3hpbzBoQ0NrdzNBZGUrL3Ri?=
 =?utf-8?B?S1g0MUhvU3poUFJqTHFjdEhUbjM2T2lwanJiSHhsRG1CSHBqbWJtWGR5SUJE?=
 =?utf-8?B?SHVDK2Fud241TDkwWTd6V0t6L2luTld1NlloMHdyU3pTK1Ywb1JMOFFrb0Jv?=
 =?utf-8?B?cjdVNVJMRURpNk5ETDJmMldqRitQSXlCc2NjNG1OaFpQVkZxczBkVDhrU2Ew?=
 =?utf-8?B?NVdaWlA2QjZ3ZFB2Ym92WjBDcGtHdU0xQjJ4WTd3SnROTmJkOW55aFpSNUhz?=
 =?utf-8?B?VEpweC84VjgrWUVxMG43ZlM3SFFFRUozd0pLbEpNa3R2Q0ZLYUdZcGd0UVpP?=
 =?utf-8?B?N0pxR1lWak10SUZ2WElFYy91R1ZGbnRLaGxvenhBR0xIQ0xZUHc3azdhYU9M?=
 =?utf-8?B?TnUwNHlwZXNEYTRwUjQvMWlreHNSMWM3aDF1bXd0dUc2ZEdob29xc3dsbGpV?=
 =?utf-8?B?RStkTVBreEphdGVIaGtNOTdvQnR2T2xZR2tHUFFFc1lDa1JnMHVSeU1CL0VL?=
 =?utf-8?B?OS95ZGZiK2h5T2VqRkMzdVI3elpmeUtsTk9GNXI0RUp5aXU4Q0dlSFdGU1Vr?=
 =?utf-8?B?K0RMenAyWDMwdEJvR2VmSWlVL3MxM1VxUUFmSmJUWDZBNktSR3VaV1JEajl5?=
 =?utf-8?B?NGhCZmV1UlRLMGcrSTZXc3RxSDFRREZhVnJhZFUzM0NTK1gwV1FJODdyS3BW?=
 =?utf-8?B?bE9mTFpROVJwTnhKemh0OTBzYkdmbUdPQ291NzFyVGxwUXk0M0pWUDB5dzJ6?=
 =?utf-8?B?MWNmdU5aT0h2bnladVJ1UmRsSWl6U3dFUU1jUHJnTEZUMC9ZWTg0Yjkxa3Nm?=
 =?utf-8?B?MDBoT2tjQlJ1dWVjb1ZLNSswQzZObUlWMHpjdWVEVWZydS9QbVRJVEVkcXVN?=
 =?utf-8?B?WTFpRUQyNEFqRktOb0JHa3BzWC9UN1pNb0RMeXoxcUtneWZHVkwrK0t2dW9B?=
 =?utf-8?B?RFo2VDZrenQ4WUFNZXZLRVJva1ZzRG16T3FUekJEVlM1ZGh1QytYUzd5cUw1?=
 =?utf-8?B?eG8zUk5ua3lRa3FLb3lLRWpHR3FWY1h6aU1zWFBRRXBRd211QjBMeEJ5Z1Rr?=
 =?utf-8?Q?wWGEpqSrrCOvXeNtMIys8HPhQftz5tyk?=
x-forefront-antispam-report: CIP:255.255.255.255; CTRY:; LANG:en; SCL:1; SRV:;
 IPV:NLI; SFV:NSPM; H:SN7PR19MB6567.namprd19.prod.outlook.com; PTR:; CAT:NONE;
 SFS:(13230040)(1800799024)(376014)(366016)(13003099007)(38070700018); DIR:OUT;
 SFP:1102; 
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0: =?utf-8?B?RzZNelVMdXh0Y1d2eWtFRE9Sb3lEWmNOYU1QaHpLZkRyOVRDS2s4SjJwM1pS?=
 =?utf-8?B?OStLTUI5L1JFeTROUGlmQ1dEOHVnd2lEd0RweFJOaW9XSGJnUkxrbzBMM0Vo?=
 =?utf-8?B?aHlIZFAyY0J0RXVBd3J2VW9FeUFoVmYrNkZmK0thek5OdVRDaDBCUDdmeFc3?=
 =?utf-8?B?WjZEY1BZNzFHUW5yc002U2tsbUNTVG0vNHhaVVZBb2dTZFNJaEE1TUovWHpv?=
 =?utf-8?B?SGFpektEby9sRFl6ek9hblVSbUVkbDAvRVhFZzF0OTRJY3JGVDRZc2FaWFVV?=
 =?utf-8?B?bUhjd0NCQTdLbFF4UHhWdWNuSE5DanM2L0VEN1NybmZtelBNa0FvWDNqLzh3?=
 =?utf-8?B?NkFaV05tMFo1Z1VQRnRLSzRkTGxhY1BpZUMzRGRMN3RmOGUxS3o5aW05MUFp?=
 =?utf-8?B?N1dVcVU1MjlLVUF6QmEvMHJRcEJxUmVZclFqNzRQN0swczBJYmQzR2xWdHIv?=
 =?utf-8?B?Y1VZYXo4b3p3a0NZWG1KK0k4SW5zWjdJcmdvbEFyRlF1RHNIL052UkdLSHhG?=
 =?utf-8?B?WFBxZVZxdlVyZDFOR1lrV24vMjVQeUM1Z3dvcWU1eDlaWEJsZ1NRYi8xdzQw?=
 =?utf-8?B?N1VyVjhYWm1wRWtqK1lLSmhMa2l5TmxlMGdjTXgxZ29qODVJY2d2ejBqNkw4?=
 =?utf-8?B?Nm5rRHNod2t3NDh3bE9KUS9vUzU2c0FrelVqcVAxQTJZVlYxWVRRUmtib1B6?=
 =?utf-8?B?Nk9RMVd4b01pakdhN3NYcVF1N1dHZGtWMWtWSGxQNkhLOWFUSTNKaVJIdFd2?=
 =?utf-8?B?TUw4RUNkR251RXpnalV0a1A0VDdVeTNaRUdiK2t4S0dNLzU0dXIrZkkwZXo2?=
 =?utf-8?B?MHhFVHBwV3VONkFDb0tRbDRtVzBqTFBSZkxXcFVOVFNOVXhvT3ZtUlpwSUhJ?=
 =?utf-8?B?dUl5ZnZHMklha0NJeFBSbEQxYVZPekhmNGc2RDlxOFcvS0dORHhSRXdMNTBN?=
 =?utf-8?B?WS9pcWhyV1UrMHpTSzhyVXZMNmtCanVWRmQ2TXVPK0dLRWpQZDFTeGZ0ditt?=
 =?utf-8?B?Y3U5YkhUOWJzQkZHVVJlaVZnazVJUXB4bUIzcktDTEFJMllqL2Q0T2N0ZllG?=
 =?utf-8?B?Sno5YTRFU2NHdHMvQmJXQzhoandVeVZrQWZYWEpvZXlCSFZrUTdaZjE3SXNj?=
 =?utf-8?B?T0k4djRCVElOVW4rN3MrVUxsbFRTc2Fmcmh0Q0xxa0x5MFNFMjRJdnpRRjBX?=
 =?utf-8?B?TGxkOXRzWW9qb3hXZW9TN2xLcGV2bFlPWnNNcXp3SkFXMmF3WG1neitmdVZJ?=
 =?utf-8?B?V2dQWXpnNnl6VENaem4rd25CMUNabTlOa2owME9ieGpqUnAvVHFZbWxQcmxh?=
 =?utf-8?B?WThqa294YlB1dVlXenZLSURnTHBPcEdlU24vbTgvSVlqZzBGeS9vM0VRaUpq?=
 =?utf-8?B?RHYyZ0tyZ2IwVGJyRndZYjNxcHNQVUVBNFB2RHh3UnBOTXNuaTFjVittT29p?=
 =?utf-8?B?alIyb2VHcE5uME1uLzRsditoNk9VU2xpcEx2eDhMa2FVTFNZZlNIMWk5U09R?=
 =?utf-8?B?R0cxUXRLeHRRNG0zZk9aMHFtRHUyMUlQN0tWVnc1bWUzS2NldVhWL2RsZ3VE?=
 =?utf-8?B?N0RGcUFGdGNoOTUwV0VsTm9NRTVURDIwdHo3KzdVTGdiMWhiaXVpaXJiK21w?=
 =?utf-8?B?Q1pOYnBnUkNsWXhCelZGS3h3ZFBYRVh1RzRqbXhKTCtKYThTMjFZbjcrYzNS?=
 =?utf-8?B?a094VVo5MWcySzgrSnA2S1Z2dVljZHhXUi93eHRqNjlMT1ZTeU9EY2xqSnJU?=
 =?utf-8?B?MHhGVHBKQmp3N290cWlJNURuTmNVMkMzTmxsamJhcWVTYnNLUkhsWkJQdmRI?=
 =?utf-8?B?dVVkQzJva1dTTVFwdW1hTXlXc1VoMWc2Y2p4RHVSYU1rckFIbHk4bEE3YlBV?=
 =?utf-8?B?YlE3enNjNlhOUVloK3dubXBkc3JiZmZTckhaS3hsUithSm8wbUVBV09kcnJL?=
 =?utf-8?B?dWRPQU1mYWo4M3Q2aHhhTXlyc3Q4d0tDSk5CYVhLOFErYWlTMU5kVDZpOUU0?=
 =?utf-8?B?V2VHVkNQOWNTUGFyU0ZwdnlPamFHYWV0MS9JT3QrUktCUnJ1NFNaSFJUdW9r?=
 =?utf-8?B?b3NTSUV2aXZOSXRWNlloRXZPcnJjY1k2YnRxZ2k2Vis0WEpoOTRIUVRGeXMv?=
 =?utf-8?Q?vZl1wi6l45AvpFSsoGjjrCO57?=
Content-ID: <6946FD4FB7AED44B8CAC3EB8D69B5C36@namprd19.prod.outlook.com>
MIME-Version: 1.0
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-0: 4U5l+/6EagAniRvrXmkssTrC0Q26QE6epi+8B3+iqry/y18fxJBxuUn4qqnCNFSdrae5WpEqST/9NN8YM34uwbtSCp+8W5QfXLYfLTSCfrr6BnW3OonBIo8ZYZJk7reQNgGIT0+o6pZGR7e/8JHT+nV3gC+Z+omaGQFYGYqZMso61Q5Dvgx9GgKDNI6AforQFSRxYcvT3FxyiOAnFbEaXIMYyZ8AQ1X8iXf+BTHyDlsaXYnUB+endlB9JwiZliBdQr3xjZhOPbCKtrFj+6sBn1aieMWSKcRQyl+GEsO7mWQAk+R0IeEiKawnY7pUHtgDvRHVO8kAjawFV24eN+78JSeMqL9qJxba3La+7m6mqjssgnk98xOLrk4eys7rnePz/weJ8z0eBk+qip/slEw6EOBlmHI3n76ZoQHFbKQ+HL0TzvjzlLXnIA+e87ng15jIg1PdY6xx1UIe/TxJ/vJbNqH5/4CoSFa+/FpDcsoGPu/qXb7AsB56UG/KL2sK1+Fb5LgAcCt8ooxV3ZYJkOKVMTnsmNZWIwDGI0kGwjaM8w7SG0u6SsR53h4esguXIa8vA6pcjkprCiTYLfz7BtqpTZvYCCgd7jY87fNx3W6YF47lgp29dQkEIxfzTRnjzYDO6XYVCQwm1wZPGsxCJgquJSMU+tGk4Y9Ii/Wr3kdUTQA=
X-OriginatorOrg: whamcloud.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: SN7PR19MB6567.namprd19.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: eb002e36-132f-4903-3c98-08dd391486f0
X-MS-Exchange-CrossTenant-originalarrivaltime: 20 Jan 2025 05:37:28.1946 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 753b6e26-6fd3-43e6-8248-3f1735d59bb4
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: KbjXP8E94vI8c00EjeqMvZtov5S5jLEwstbkxWoZAW/2Y0orrgkEFPHYd763KyGp
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SJ2PR19MB8096
X-BESS-ID: 1737351452-105647-16794-44243-1
X-BESS-VER: 2019.3_20250117.1903
X-BESS-Apparent-Source-IP: 104.47.70.48
X-BESS-Parts: H4sIAAAAAAACA4uuVkqtKFGyUioBkjpK+cVKVuZGBhZAVgZQ0NAo2SIpyTQlyT
 IpzcTcwtDMMsnSJNXYMtkcyDI3S1OqjQUAFMJMN0EAAAA=
X-BESS-Outbound-Spam-Score: 0.00
X-BESS-Outbound-Spam-Report: Code version 3.2,
 rules version 3.2.2.261928 [from 
 cloudscan12-197.us-east-2a.ess.aws.cudaops.com]
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

T24gTW9uLCAyMDI1LTAxLTIwIGF0IDA0OjM4ICswMDAwLCBEYXksIFRpbW90aHkgd3JvdGU6DQoN
Cj4gSSB0aGluayBldmVyeSBvcmdhbml6YXRpb24gdGhhdCB1c2VzIEx1c3RyZSBoYXMgYSBtb2Rl
bCBzaW1pbGFyIHRvDQo+IHRoaXMuIEJ1dCBJIGRvbid0IHRoaW5rIHRoaXMgaXMgdW5jb21tb24g
Zm9yIG90aGVyIHN1YnN5c3RlbXMuIFRoZQ0KPiB2YXJpb3VzIE9GRUQgZmxhdm9ycyBjb21lIHRv
IG1pbmQgKEkgdGhpbmsgTU9GRUQgd2FzIG1lbnRpb25lZA0KPiBpbiBhbm90aGVyIHRocmVhZCku
IEV2ZXJ5dGhpbmcgaXMgdWx0aW1hdGVseSByZWJhc2VkIG9uIHRoZQ0KPiBjb21tdW5pdHkgdmVy
c2lvbiwgQUZBSUsuDQoNCk15IHVuZGVyc3RhbmRpbmcgb2YgbW9mZWQgaXMgdGhleSBhcmUgaW4g
ZXhhY3RseSB0aGUgc2FtZSBib2F0IHdlIGFyZQ0KaG9waW5nIHRvIGF2b2lkOiAicmVtb3ZlIHdo
YXRldmVyIHBpdGlmdWwgc3R1ZmYgdGhlcmUgaXMgaW4gdGhlIGxpbnV4DQprZXJuZWwgYW5kIHRo
ZW4gcGx1ZyBpbiBvdXIgb3duIHN1cGVyaW9yIHN0dWZmIg0KDQo+ID4gQm90aCBERE4gYW5kIEhQ
RSBzaWduaWZpY2FudGx5IGRpdmVyZ2Ugd2l0aCBuZXcgZmVhdHVyZXMgYW5kIHN1Y2guDQo+ID4g
VGhlcmUncyBhbHNvIGEgKG5vdyBtb3N0bHkgZG9ybWFudCkgRnVqaXRzdSAiRkVGUyIgZm9yayB0
aGF0IHRoZXkNCj4gPiBnb3QNCj4gPiB0aXJlZCBvZiBtYWludGFpbmluZyBhbmQgdHJpZWQgdG8g
Zm9sZCBiYWNrIGluLCBidXQgY291bGQgbm90Lg0KPiA+IChhbHNvDQo+ID4gQ3JheSdzIHNlY3Vy
ZSBkYXRhIGFwcGxpYW5jZSB0aGF0IHNlZW1zIHRvIGhhdmUgbWV0IGEgc2ltaWxhciBmYXRlOg0K
PiA+IGh0dHBzOi8vZ2l0aHViLmNvbS9DcmF5L2x1c3RyZS1zZGHCoDwNCj4gPiBodHRwczovL2dp
dGh1Yi5jb20vQ3JheS9sdXN0cmUtc2RhPiApDQo+ID4gDQo+ID4gDQo+ID4gWWVzLCBtYWludGVu
YW5jZSBidXJkZW4gY29uc2lkZXJhdGlvbiBpcyBhbHdheXMgdGhlcmUgb2YgY291cnNlLCBzbw0K
PiA+IHRoZXJlJ3Mgc29tZSBjb29yZGluYXRpb24gbm93YWRheXMgKGxpa2UgcmVzZXJ2aW5nIGZl
YXR1cmUgZmxhZ3MNCj4gPiBhaGVhZA0KPiA+IG9mIHRpbWUgYW5kIHN1Y2gpLCBidXQgaXQncyBu
b3Qgb3V0c2lkZSBvZiByZWFsbSBvZiBwb3NzaWJpbGl0eQ0KPiA+IHRoYXQgaWYNCj4gPiB3aGF0
J3MgcGVyY2VpdmVkIGFzICJ0aXAgb2YgdGhlIGNvbW11bml0eSB0cmVlIiBiZWNvbWVzDQo+ID4g
aW5jb252ZW5pZW50LA0KPiA+IGl0J2xsIGJlIGRyb3BwZWQuDQo+ID4gSW4gZmFjdCBhIHNpbWls
YXIgdGhpbmcgaGFwcGVuZWQgdG8gdGhlIHN0YWdpbmcgbHVzdHJlIGluIHRoZSBwYXN0DQo+ID4g
SQ0KPiA+IGd1ZXNzLCBvbmx5IGJlZm9yZSBpdCBldmVuIGJlY2FtZSB0aGUgcGVyY2VpdmVkIHRp
cCAoZm9yIGEgdmFyaWV0eQ0KPiA+IG9mDQo+ID4gcmVhc29ucykuDQo+IA0KPiBCb3RoIERETiBh
bmQgSFBFIHJlZ3VsYXJseSBjb250cmlidXRlIGZpeGVzL2ZlYXR1cmVzIGJhY2sgdG8gdGhlDQo+
IGNvbW11bml0eQ0KPiBicmFuY2ggZnJvbSB0aGVpciByZXNwZWN0aXZlIHByb2R1Y3Rpb24gYnJh
bmNoZXMuIEhQRSBzZWVtcyB0byByZWJhc2UNCj4gdGhlaXIgYnJhbmNoZXMgZmFpcmx5IG9mdGVu
IG9uIGNvbW11bml0eSBMdXN0cmUgWzFdLiBZb3Ugd291bGQgaGF2ZQ0KPiBtb3JlDQo+IGNvbnRl
eHQgaWYgdGhhdCdzIHRydWUgZm9yIERETiAtIEkgY291bGRuJ3QgZmluZCBtdWNoIG9ubGluZS4N
Cg0KeWVzLCB0aGVyZSBtZXJnZXMgYW5kIHJlYmFzZXMgYXJlIHJlbGF0aXZlbHkgY29tbW9uIGZv
ciBhcyBsb25nIGFzIGl0DQpyZW1haW5zIGNvbnZlbmllbnQuIEF0IHlvdXIgQ3JheSBsaW5rIHlv
dSBtaWdodCBhbHNvIG5vdGljZSB0aGUgcmViYXNlcw0KYXJlIG5vdCBvbiB0b3Agb2YgbWFzdGVy
Lg0KDQo+IEJ1dCBGdWppdHN1IGFuZCB0aGUgU0RBIHRlYW0gaW4gSFBFIHdlcmUgbm90IGNvbnRy
aWJ1dGluZyBiYWNrIGFzDQo+IG11Y2ggYW5kIGV2ZW50dWFsbHkgYWJhbmRvbmVkIHRoZWlyIGZv
cmtzLiBTbyBiYXNlZCBvbiB0aG9zZQ0KPiBleGFtcGxlcywNCj4gaXQgc2VlbXMgbW9zdCBzdXN0
YWluYWJsZSBmb3Igb3JnYW5pemF0aW9ucyB0byBjb250cmlidXRlIHRvIHRoZQ0KPiBjb21tdW5p
dHkNCj4gcmVsZWFzZS4gU28gSSB0aGluayB0aGUgcmlzayBvZiBjb250cmlidXRpb25zIGJlaW5n
IGxlc3NlbmVkIGJlY2F1c2UNCj4gTHVzdHJlDQo+IG1vdmVzIHRvd2FyZHMgdXBzdHJlYW0gaXMg
bG93LCBJTUhPLg0KPiANCj4gQnV0IEkgYWdyZWUgd2l0aCB5b3VyIGZ1bmRhbWVudGFsIHBvaW50
IC0gd2UgY2FuJ3QgbWFrZSBzdWJtaXR0aW5nDQo+IHBhdGNoZXMNCj4gdG8gY29tbXVuaXR5IEx1
c3RyZSBhcmR1b3VzLg0KDQpJIHNraXBwZWQgdGhlIHByZWNlZGluZyBwYXJ0cywgYnV0IHRoaXMg
aXMgcHJvYmFibHkgZ29pbmcgdG8gYmUgdGhlDQptYWluIHBvaW50IG9mIGNvbnRlbnRpb24uDQpU
aGUgcmVhc29ucyBGRUZTIGRyb3BwZWQgb3V0IGlzIGJlY2F1c2UgdGhleSBkaWQgdGhleSBkZXZl
bG9wbWVudCBpbg0Kc2VjcmV0IHdpdGhvdXQgdGFsa2luZyB0byBhbnlvbmUgbWFraW5nIGNob2lj
ZXMgd2UgKHRoZSAibWFpbmxpbmUiDQpMdXN0cmUgcGVvcGxlKSBmb3VuZCB1bndpc2Ugb3IgcXVl
c3Rpb25hYmxlLg0KU28gb25jZSBGdWppdHN1IGNhbWUgdG8gdXMgd2l0aCAiaGV5LCB3ZSBoYXZl
IHRoaXMgd2hvbGUgYnVuY2ggb2YNCmF3ZXNvbWUgc3R1ZmYiLCBhIGxvdCBvZiBpdCBoYWQgdG8g
YmUgcmVqZWN0ZWQgYmVjYXVzZSBpdCB3YXMgbm90IGRvbmUNCmluIGEgZ29vZCB3YXkgb3IgdGhl
cmUgd2FzIGEgY29tcGV0aW5nIGltcGxlbWVudGF0aW9uLg0KDQpOb3cgdGhlIHRhYmxlcyBhcmUg
dHVybmluZyBhcyBJIGV4cGxhaW5lZC4gV2UgYXJlIGRvaW5nIGRldmVsb3BtZW50ICJpbg0Kc2Vj
cmV0IiAoYXMgZmFyIGFzIGtlcm5lbCBtYWludGFpbmVycyBhcmUgY29uY2VybmVkLCBhbnl3YXkp
Lg0KPiANCj4gWzFdIGh0dHBzOi8vZ2l0aHViLmNvbS9DcmF5L2x1c3RyZQ0KPiANCj4gPiA+ID4g
U3VyZSwgb25seSBvbmUgb2YgdGhvc2UgdHJlZXMgaXMgY29uc2lkZXJlZCAiY29tbXVuaXR5IEx1
c3RyZSIsDQo+ID4gPiA+IGJ1dA0KPiA+ID4gPiBpZg0KPiA+ID4gPiBpdCB3aWxsIGRldGFjaCB0
b28gbXVjaCBmcm9tIHdoYXQgbWFqb3JpdHkgb2YgZGV2ZWxvcGVycyByZWFsbHkNCj4gPiA+ID4g
cnVucw0KPiA+ID4gPiBhbmQgZ2V0cyBwYWlkIHRvIGRvIC0gdGhlICJjb21tdW5pdHkgTHVzdHJl
IiBjb250cmlidXRpb25zDQo+ID4gPiA+IHByb2JhYmx5DQo+ID4gPiA+IHdvdWxkIGRpbWluaXNo
IGdyZWF0bHksIEkgYW0gYWZyYWlkLg0KPiA+ID4gDQo+ID4gPiBBcyBsb25nIGFzIHRoZSBjb21t
dW5pdHkgTHVzdHJlIGRldmVsb3BtZW50IHByb2Nlc3MgaXMgc2FuZSwgSQ0KPiA+ID4gdGhpbmsN
Cj4gPiA+IG1vc3Qgb3JnYW5pemF0aW9ucyB3aWxsIG9wdCB0byBjb250aW51ZSBkZXJpdmluZyB0
aGVpciByZWxlYXNlcw0KPiA+ID4gZnJvbQ0KPiA+ID4gaXQgYW5kIG9wdCB0byBjb250aW51ZSBj
b250cmlidXRpbmcgcmVsZWFzZXMgdXBzdHJlYW0uIFdlIGp1c3QNCj4gPiA+IG5lZWQNCj4gPiA+
IHRvIG1ha2Ugc3VyZSB3ZSBnZXQgYnV5LWluIGZyb20gdGhlIHBlb3BsZSBjb250cmlidXRpbmcg
dG8NCj4gPiA+IEx1c3RyZS4NCj4gPiANCj4gPiANCj4gPiBXZWxsLCB0aGVyZSdzIGFub3RoZXIg
aGFsZiBvZiBpdCwgdGhlIGtlcm5lbCBzaWRlLiBQcmV2aW91cyBydW4gaW4NCj4gPiB3aXRoDQo+
ID4gb3RoZXIga2VybmVsIG1haW50YWluZXJzIGhhZCBsZWZ0IGEgYml0IG9mIGEgc291ciB0YXN0
ZSBpbiBwZW9wbGUncw0KPiA+IG1vdXRocy4NCj4gPiBPZiBjb3Vyc2UgdGhleSBoYXZlIHRoZWly
IG93biByZWFzb25zIHRvIGRpY3RhdGUgd2hhdGV2ZXIgdGhleSB3YW50DQo+ID4gdG8NCj4gPiBu
ZXdjb21lcnMgKEFuZCBhbGwgY29taW5nIHBhdGNoZXMpLCBidXQgb24gdGhlIG90aGVyIGhhbmQg
THVzdHJlIGlzDQo+ID4gYQ0KPiA+IG1hdHVyZSBwcm9kdWN0IHRoYXQgY291bGQgbm90IGp1c3Qg
ZHJvcCBldmVyeXRoaW5nIGFuZCByZXdyaXRlDQo+ID4gc2lnbmlmaWNhbnQgY2h1bmtzIG9mIHRo
ZSBjb2RlIChzZXZlcmFsIHRpbWVzIGF0IHRoYXQpIG8gYmV0dGVyDQo+ID4gYWxpZ24NCj4gPiB3
aXRoIHRoZSBldmVyIGNoYW5nZWQgZGVtYW5kcyAoYmNhY2hlZnMgSSB0aGluayB3YXMgYSBoaWdo
bHkNCj4gPiBwYXJhZGVkDQo+ID4gYXJvdW5kIGV4YW1wbGUgb2YgdGhhdCwgYW5kIHRoZXkgY291
bGQgYWNjb21tb2RhdGUgdGhvc2Ugb2Z0ZW4NCj4gPiBjb25mbGljdGluZyBkZW1hbmRzIGJlY2F1
c2Ugbm90IG1hbnkgZGVwbG95bWVudHMgaW4gdGhlIHdpbGQpLg0KPiA+IEkgZG9uJ3Qga25vdyBo
b3cgcG9zc2libGUgaXMgaXQgdG8gb3ZlcmNvbWUuIEtlcm5lbCBtYWludGFpbmVycw0KPiA+IGRv
bid0DQo+ID4gcmVhbGx5IGNhcmUgYWJvdXQgTHVzdHJlIChhbmQgcmlnaHRmdWxseSBzbywgd2Ug
YXJlIGJ1dCBhIGJsaXAgdG8NCj4gPiB0aGVtKQ0KPiA+IGFuZCB0aGVuIHdlIGFsc28gaGF2ZSBv
dXIgb3duIHByaW9yaXRpZXMuDQo+IA0KPiBMU0YvTU0gY291bGQgYmUgYSBnb29kIG9wcG9ydHVu
aXR5IHRvIGltcHJvdmUgb3VyDQo+IHJlbGF0aW9uc2hpcCB3aXRoIHRoZSB1cHN0cmVhbSBtYWlu
dGFpbmVycy4gOikNCg0KQWJzb2x1dGVseS4gVGhvdWdoIHdlIGRpZCBnbyB0aGVyZSBpbiB0aGUg
cGFzdCwgYW5kIGhhZCB0aGUgZGlzY3Vzc2lvbnMNCmFuZCBhbGwsIGFuZCB0aGVyZSdzIG5vIGlu
Y2VudGl2ZSBmb3IgdGhlIGtlcm5lbCBtYWludGFpbmVycyB0byBhY2NlcHQNCm91ciB3YXkgYmVj
YXVzZSBvYnZpb3VzbHkgZm9yIHRoZW0gaXQncyBhIGJhZCBwcm9jZXNzIChhbmQgSSBkb24ndA0K
YmxhbWUgdGhlbSEpDQoNCj4gPiBBbmQgd2hpbGUgZm9yIEx1c3RyZSBkZXZlbG9wZXJzIHRoZXJl
J3MgYSBiZW5lZml0IG9mICJ0aGUgYWRqdXN0aW5nDQo+ID4gdG8NCj4gPiBuZXcgaW50ZXJmYWNl
cyBjb21lcyBmb3IgZnJlZSIsIHRoZXJlJ3Mgbm8gYmVuZWZpdCB0byB0aGUga2VybmVsDQo+ID4g
bWFpbnRhaW5lcnMsIHNvIHRoZXkgZG9uJ3QgaGF2ZSBtdWNoIGluY2VudGl2ZS4NCj4gPiAoYW5k
IGFnYWluIHdlIHNhdyB0aGlzIGluIHRoZSBwcmV2aW91cyBhdHRlbXB0KQ0KPiA+IA0KPiA+IA0K
PiA+IEFuZCBldmVuIGltYWdpbmUgYnkgc29tZSBtYWdpYyB0aGUgYWN0dWFsIGluY2x1c2lvbiBh
bmQgYWxsIHRoZQ0KPiA+IHJlbGV2YW50IHJld29yayBoYXBwZW5lZC4gTm93IEhQRSBvciBERE4g
d2FudHMgdG8gYWRkIGEgbmV3DQo+ID4gZmVhdHVyZSwNCj4gPiB0aGV5IGltcGxlbWVudCBpdCBh
bmQgdGhlbiBzdWJtaXQgYW5kIGEgbWV0IHdpdGggdGhlIHVzdWFsICJub3cNCj4gPiByZXdvcmsN
Cj4gPiBpdCBpbiB0aGVzZSBvdGhlciB3YXlzIiBkZW1hbmRzLg0KPiA+IE9mIGNvdXJzZSBhZ2Fp
biBmcm9tIHRoZSBrZXJuZWwgbWFpbnRhaW5lcnMgcGVyc3BlY3RpdmUgdGhpcyBpcw0KPiA+IGVu
dGlyZWx5IHJlYXNvbmFibGUgYW5kIGl0J3Mgbm90IHRoZWlyIHByb2JsZW0gdGhlIGRldmVsb3Bt
ZW50DQo+ID4gcHJvY2Vzcw0KPiA+IGlzIHdyb25nIGFuZCBiYWNrd2FyZHMgYW5kIGluc3RlYWQg
b2YgZGV2ZWxvcGluZyBldmVyeXRoaW5nIGluIHRoZQ0KPiA+IG9wZW4NCj4gPiBvbiB0aGUgcHVi
bGljIGJyYW5jaCB3aXRoIGlucHV0IGZyb20gYWxsIHBhcnRpZXMgaW50ZXJlc3RlZCB0aGVyZSdz
DQo+ID4gdGhpcyBjbG9zZWQgZGV2ZWxvcG1lbnQgZ29pbmcgb24uIEJ1dCBnb29kIGx1Y2sgY29u
dmluY2luZw0KPiA+IHJlc3BlY3RpdmUNCj4gPiBtYW5hZ2VtZW50IG9mIHRob3NlIGNvbXBhbmll
cyB0byBhZ3JlZS4NCj4gDQo+IEJhY2twb3J0aW5nIGZyb20gcHJvZHVjdGlvbiBicmFuY2hlcyB0
byB0aGUgY29tbXVuaXR5IHJlbGVhc2UNCj4gYWxyZWFkeSB0YWtlcyBzb21lIHdvcmsuIEVzcGVj
aWFsbHkgaW4gdGhlIGZlYXR1cmUgaXMgYmFzZWQgb24gYW4NCj4gb2xkZXIgTFRTLiBTbyBJIGRv
bid0IHRoaW5rIHBvcnRpbmcgdG8gdXBzdHJlYW0gTGludXggd291bGQgYmUgYSBodWdlDQo+IGFt
b3VudCBvZiBleHRyYSB3b3JrLg0KDQpEZXBlbmRzIG9uIGhvdyBtdWNoIGV4dHJhIGZyaWN0aW9u
IHRoZSBrZXJuZWwgYWNjZXB0YW5jZSBhZGRzIChmcm9tDQpleHRyYSByZXZpZXdzIGJ5IGZzL21t
IG1haW50YWluZXJzKSBhbmQgSSBlc3RpbWF0ZSBpdCB0byBiZSBoaWdoDQppbml0aWFsbHkuDQpE
b24ndCBmb3JnZXQgYWxsIHRoZSAicHJvcHJpZXRhcnkiIGZlYXR1cmVzIHRoYXQgYXJlIG5vdCBp
biBtYWlubGluZSwNCmJ1dCBhcmUgZnVsbHkgZGV2ZWxvcGVkIG90aGVyd2lzZS4gSG93IG1hbnkg
b2YgdGhvc2UgaW1wbGVtZW50YXRpb24NCmRldGFpbHMgd291bGQgbm90IGJlIGxpa2VkIGJ5IHRo
ZSBrZXJuZWwgbWFpbnRhaW5lcnMgaXMgYSBiaWcgdW5rbm93bi4NCg0KPiBPbiB0aGUgb3RoZXIg
aGFuZCwgaWYgTHVzdHJlIHdhcyBpbmNsdWRlZCBpbiBtYWlubGluZSBwcm9wZXJseSByYXRoZXIN
Cj4gdGhhbiBpbiBzdGFnaW5nIC0gSSB0aGluayB3ZeKAmWQgaGF2ZSBtb3JlIGxldmVyYWdlIHRv
IGltcGxlbWVudCB0aGluZ3MNCj4gdGhlIHdheSB3ZSB3YW50IHRvLiBBZnRlciBhbGwsIHRoZSBr
ZXJuZWwgbWFpbnRhaW5lcnMgZG9uJ3QgcmVhbGx5DQo+IGNhcmUNCj4gYWJvdXQgTHVzdHJlLiA6
KQ0KDQpUaGV5IGNhcmUgYWJvdXQgdGhlIHdheSBpbnRlcmZhY2VzIGFyZSB1c2VkLCB0aGF0IHdh
cyBhIHByZXR0eSBiaWcNCnBvaW50IG9mIGNvbnRlbnRpb24gaW4gdGhlIHBhc3QgYW5kIEkgc3Vy
ZSBzdGlsbCByZW1haW5zLg0KSGF2ZSB5b3Ugc2VlbiBhbGwgdGhlICJuaWNlIiBzdHJpbmcgbWF0
Y2hpbmcvdXNlcnNwYWNlIG1lbW9yeSBwYXJzaW5nDQp3ZSBkbyBmb3IgdGhlIGpvYmlkIGRldGVy
bWluYXRpb24gZm9yIGV4YW1wbGU/IFllYWgsIEkgZG9uJ3QgbGlrZSBpdA0KZWl0aGVyLg0KQnV0
IHRoZXkgYWxzbyBkb24ndCBsaWtlIG90aGVyIHRoaW5ncyB0b28uDQpEZWZpbml0ZWx5IHRhbGsg
dG8gaGNoLCBoZSBoYXMgY2hvaWNlIHdvcmRzIGFib3V0IG1hbnkgcGFydHMgb2YgTHVzdHJlDQoo
aWYgaGUgc3RpbGwgZGlkIG5vdCBmb3JnZXQpLg0KDQpJIHJlYWxseSB3YW50IHRvIGJlIG9wdGlt
aXN0aWMgYWJvdXQgaXQsIGJ1dCBJIGFsc28gc3RpbGwgcmVtZW1iZXIgdGhlDQpwcmV2aW91cyBh
dHRlbXB0IHZpdmlkbHkgYW5kIG1ham9yaXR5IG9mIG9iamVjdGlvbnMgcmFpc2VkIGJhY2sgdGhl
bg0KYXJlIHN0aWxsIHByZXR0eSB2YWxpZC4NCg0KDQpfX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fXwpsdXN0cmUtZGV2ZWwgbWFpbGluZyBsaXN0Cmx1c3RyZS1k
ZXZlbEBsaXN0cy5sdXN0cmUub3JnCmh0dHA6Ly9saXN0cy5sdXN0cmUub3JnL2xpc3RpbmZvLmNn
aS9sdXN0cmUtZGV2ZWwtbHVzdHJlLm9yZwo=
