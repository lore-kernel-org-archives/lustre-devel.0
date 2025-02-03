Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 0E329C02192
	for <lustre-devel@archiver.kernel.org>; Mon,  3 Feb 2025 19:45:40 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Ymxkr2VlTz1xPk;
	Mon, 03 Feb 2025 11:43:48 -0800 (PST)
Received: from outbound-ip191a.ess.barracuda.com
 (outbound-ip191a.ess.barracuda.com [209.222.82.58])
 (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4YmxkK1RdSz1wTN
 for <lustre-devel@lists.lustre.org>; Mon, 03 Feb 2025 11:43:21 -0800 (PST)
Received: from NAM11-BN8-obe.outbound.protection.outlook.com
 (mail-bn8nam11lp2176.outbound.protection.outlook.com [104.47.58.176]) by
 mx-outbound10-63.us-east-2a.ess.aws.cudaops.com (version=TLSv1.2
 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
 Mon, 03 Feb 2025 19:42:40 +0000
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=Uw6qwawM+p4hRPhDFvjovNmQ6gjoDDR1JgR+Mz1icO4xgAiFN71A1CKcauZ6u6HXv03a2p1xwwrxroMWOr39HKrZutflfF7kYATxlIIADiXoOn638hg44egOLO1P4QhSJGmcNrIeUDBULt7PuoseOqoZ92wbR1YyzCS1vNMvIcRVGcHAnU8HU/Eq3CYLFF9VTgYAGCPqThuJ2pgdw3T0nVwmbPxuvDNdkPQFsnWCOcjCbnZ1qRWv5wjzNOhRQxaRvlrhX+2WEIHBoZztwaIcwPsX4xrADRwvkVNLWBxN1nnVar2m+ZXPxY2xMTWGLFGLbD59HNYKpWyQ3XOwtcV7zw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com; 
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=34s8wfvy1yCojZgrxOGWd83T6CvS8KCpUf8DWlr/cbw=;
 b=UZqDggVuFiFNwpypoTuzlb8Xr4jwXCXZPbEJfc5bowaq+jCVSUWuQ65yaOqiXyUQVj55GoOlztHFM2XxVe2Pbmy0sF32QLdUQnP/c+np2GnPUF0vIWFPDlGbIP5wca2rAk0M/rNF9xwJLKzSoU84auTc+xbBTMua66Dm0ih27+G3HashNzIph5Rl3dKCeG/POhDtstLyEQTFhwuw1Qav7ECVq5gCOJT96ss8+vFv6EXXNtoOzTnRD9jbcNCpltAdp8f3verxnkY+UQSA0fHoO0HkHVcZAUVj49SPGDlj2rvGiIslXcYcLx8kjDg3lzQsIkt+HSBdYJOhwuMOy+kjUA==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=whamcloud.com; dmarc=pass action=none
 header.from=whamcloud.com; dkim=pass header.d=whamcloud.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=whamcloud.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=34s8wfvy1yCojZgrxOGWd83T6CvS8KCpUf8DWlr/cbw=;
 b=fcAHHfZa4duy2EaMrxa3j3WjRwGhcauZvvaG3fBRMi0DwCrxxfM5tnyHjoW0yJvzdWk4/sJ0WZX60e2Emeb96Rx5V/XZiWE7vvytWuH2zHO+xOSy7YBZhX0orm4Ip5wpYzNwn1mnV46FwuwnbZTo3IHSRzrp4HpQb+XtnuW4hDE=
Received: from SN7PR19MB6567.namprd19.prod.outlook.com (2603:10b6:806:26d::11)
 by SN7PR19MB7042.namprd19.prod.outlook.com (2603:10b6:806:2a9::14)
 with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.8398.17; Mon, 3 Feb
 2025 19:42:38 +0000
Received: from SN7PR19MB6567.namprd19.prod.outlook.com
 ([fe80::db50:586b:7dda:cf04]) by SN7PR19MB6567.namprd19.prod.outlook.com
 ([fe80::db50:586b:7dda:cf04%3]) with mapi id 15.20.8398.020; Mon, 3 Feb 2025
 19:42:37 +0000
From: Oleg Drokin <green@whamcloud.com>
To: "timday@amazon.com" <timday@amazon.com>, "neilb@suse.de" <neilb@suse.de>
CC: "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>
Thread-Topic: [lustre-devel] [LSF/MM/BPF TOPIC] [DRAFT] Lustre client
 upstreaming
Thread-Index: AQHbaF06daQEbe3e/kelMir67rT0hbMbs8GAgAAqWwCAAUdfgIABebkAgAf62QCAAH1kAIAMBm2AgAASkoCAAr/pAIAAJnkA
Date: Mon, 3 Feb 2025 19:42:36 +0000
Message-ID: <3ce0efd54f2bf45e84882de0e1b469caf1f74397.camel@whamcloud.com>
References: <d008c14bba74e39999ae70af871740a5d0c5c6eb.camel@whamcloud.com>
 <173844834301.22054.134358817491003595@noble.neil.brown.name>
 <82e4528eb0f4961bdc6b065dfcabea03c1a9face.camel@whamcloud.com>
 <AFA09EE9-0679-4484-8571-F03F7DEE20EC@amazon.com>
In-Reply-To: <AFA09EE9-0679-4484-8571-F03F7DEE20EC@amazon.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=whamcloud.com;
x-ms-publictraffictype: Email
x-ms-traffictypediagnostic: SN7PR19MB6567:EE_|SN7PR19MB7042:EE_
x-ms-office365-filtering-correlation-id: cdb74614-1c79-4c08-4f8d-08dd448ae984
x-ms-exchange-senderadcheck: 1
x-ms-exchange-antispam-relay: 0
x-microsoft-antispam: BCL:0; ARA:13230040|1800799024|366016|376014|38070700018;
x-microsoft-antispam-message-info: =?utf-8?B?REQ5RkFSSzY0ZHljN3kzYWo2UkNHSWJ5NkZyMFA5RGdHMXpuNm94QWQ5em9D?=
 =?utf-8?B?MmRyZlNxdmZmOWt6eHhZaHowNkttSVk5L24yUXpmcjdwdEQ1OVNtbmlzbU8z?=
 =?utf-8?B?aXVuTjd3MGY3c1BLdzMvL20zRWNpOC9IcTlXSHR6MVlyT1dFTEpKcXZOTG1N?=
 =?utf-8?B?RmlDRk4zWXVzUU96dEN3WDdCTDFNMHZpTXMwU1RYOTA5YW04NDQzbFBORkNO?=
 =?utf-8?B?Qk5TNS9ZOEZNNmsyTllFNHVpeWV5WG1VSk1GQUhybGs2WGozTS9QSlkyYVZX?=
 =?utf-8?B?OHd0RVJOTGYvaFNwWkphSEtSc1QyM1JaK1JGT0l5dzZhWGh1R0dzVFRLaFF2?=
 =?utf-8?B?UWpwNVJsTjNUcmd3V1drbXdKamRONURuTHQ2VHV5d3VUenZIdnliQWkwYVpF?=
 =?utf-8?B?U2pER291VUR3b2lLM3YwWjltR0FicDYrV2RBM2pqT0N2WW1qcHFYR3RoUlNU?=
 =?utf-8?B?WGFiNVZSTjRaWmhjZ2pIcENaTVFRZENZRFFPQ05NUVZkMGIzc3ZwMThKVzRs?=
 =?utf-8?B?am9XeXdsM3d0UmRORTZyUkFWNnQxMGh5VXYxL3Jva3lWUm1XajZodVJuczNo?=
 =?utf-8?B?TTBIdURVeUx1SlhUTTZsTEJsUW42NzlZVUpqVFZMdkdTK1NZb0p4amJ4ZC9E?=
 =?utf-8?B?eE1QZ0ZMaHRsd3RibDlXcSsveDAzRUhUVFErRi8zSUhla0pXbTJGYko0b2RR?=
 =?utf-8?B?ZGNJbzFQMFVCbGE1Zm1CdzJ4eHFzTDJjQ3RyUGJSNUQxRFdtVlFSS2llbEd5?=
 =?utf-8?B?cmpwaFFJZHdScU5BaHRyK0lpVzlIQXZqM3Y5KzdVd3AwYVNMN014SEhjdzlU?=
 =?utf-8?B?ajh4OHZjaEhuNmpjZnBpUVZYVHhKWGxDY2NWNlZJWnY5ajlldHoxOWp2Ukxt?=
 =?utf-8?B?aldweHdQa09waDlyTHJCcGZpaWU0WnExajloYkFWQVZzTVQ2aXRtclN3a1Fj?=
 =?utf-8?B?VHFvQ3UvbVFBRi9Rbk9zRjdTUWhzUy9EMGgxVlRuQnBMTzhXSWo4b2ZLbFA2?=
 =?utf-8?B?RnFvNC9wZU1JenZQMWdRY0lYOE1LRHh4YVJGS3ovempjRjRNL1l4YWh6Zk4r?=
 =?utf-8?B?TUhhdXJRVk9xWVZ1OUM1SkhnUklucXUwaDdqOHRvT2FtSE5zQm5BSlI4Q0th?=
 =?utf-8?B?ckZnMXNPVUZSZ0l1SDZDbDV6VGNGcWhrTE03MmNTSkVWM2pUMmZXZTV5VUtD?=
 =?utf-8?B?d3hOVURsQVBhY0ovZjRERzJCQzAySzMwSDdoN0xsaGYzOFU4L1k4WTZPUWpo?=
 =?utf-8?B?ZXlMZGlGc04wbGtoMEpNNVVkaHFGNms5bTNGR3ZsT1U2VmxkMjBmc1R1S3VL?=
 =?utf-8?B?eE5GeDZOZzYycFo4aHpZREdEdU5xRW1hcUhxU0tRSEZ3ZWN6d1dyemR4Q3ky?=
 =?utf-8?B?UjU2dDh5am0yNmxNK2x6N0VFQjRMWFVNOHlacHpGN25CSUg4TUFSY2RuMmky?=
 =?utf-8?B?VjVUOWhUbTdXZmdmVUhXMTkwc2JnNU4rK1drc0ZkREFpblJJQ0xrcEJiY0ZB?=
 =?utf-8?B?aHVnendNckxRa0Y2cUQrSU5SUm4vMCs1Z1V1ZFk0WUNZRnJ3SjZTZGNpTFB2?=
 =?utf-8?B?MUZwOHFQSzljdWxDdE1GRElVOHdtRlZiWkZiVzd1SFl0c3p6ZU9hWENVL2Yy?=
 =?utf-8?B?ckpPOHBJaTArU2h5U3I3Q05qZnJtSm1KbE5PeEZNbWJGa3cxVUovdmlHa0Jr?=
 =?utf-8?B?SUhzSkNmYkNFT01WbTFadURqQnJ0RWJ4M0xxWTN2QmM0VjZKZG1sdWxQRC8r?=
 =?utf-8?B?T0locUszcXZ0LytOVnhBQWlTSkQvMCtlYytiL3dWaU9ZQS9GYSt6M0xOYmgz?=
 =?utf-8?B?WC95OWRBY1lybVRYWVcreVE4MGI0Q0c3eElReWlIcUQ3WmJ0aDVnVmdjMHZB?=
 =?utf-8?B?U2JkZ3dnNjhSZGZaaUx6ZURHOE5wb1FZeEEzY3pBeUlKZDArQlBQN2NEWjlr?=
 =?utf-8?Q?KlPNX71x1BHzejY1IL2tL479h6qk+Eah?=
x-forefront-antispam-report: CIP:255.255.255.255; CTRY:; LANG:en; SCL:1; SRV:;
 IPV:NLI; SFV:NSPM; H:SN7PR19MB6567.namprd19.prod.outlook.com; PTR:; CAT:NONE;
 SFS:(13230040)(1800799024)(366016)(376014)(38070700018); DIR:OUT; SFP:1102; 
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0: =?utf-8?B?ejNiU3F1VVZXdDdueGpUSDFrbXl1MEhXTlh4MjJVR05LQzZtOExSVkpIRlRv?=
 =?utf-8?B?Ry8zRVBWTUlLVDczR2xhNHJtYmg5TzVjWm5MWTN4cG05VlhsT3o1d3lUbFBq?=
 =?utf-8?B?bVFRRjhhQ3d1MmJCaHNMdmlXZllXT0IvZDh5bS9wZDNCN3Jham5OdFFoRTls?=
 =?utf-8?B?ZDNKTTJHQzFja2hKZndiVEdPZENYWW5jRVdSQk9BZzdaS09HQ3Y1b2xZaVIw?=
 =?utf-8?B?RXpzVUZDekQraXFTQTJkMXlMdS9Xd2M1SS9HTmQ3YUhHYmlPOW50cllOUkRH?=
 =?utf-8?B?MDJFVEV2R3FWSXJiVUJwSXF5N2thaU50TkN4c2Z4bU5NL1ptclFleXpnTzRs?=
 =?utf-8?B?OCtodTVRUGVZQjRjbERMWXFvamhhMmhuZCtNYU9ua2JCaDEwcUZUMStOY2Ey?=
 =?utf-8?B?MWZKVlpGS1pYek5GWVRuUm9sMkFSTzR4UXRRdlc1NVJVMGQ5UEhhZGJIbmZr?=
 =?utf-8?B?T1VqOS9TR0dhNTg3Uzk4MmJCUHI4MitBci9ZTnZ0alRrOTAvTlphS1ZscXJO?=
 =?utf-8?B?dFFxNktaTkFBU1l3WEJJRkhSOUxzd0d4SVgwWXRJUFFHZDgwR0YxVEttYytw?=
 =?utf-8?B?eWtjRkZWSlgxVCtEd29KV0ZrVi9mSU5kK0JEczd0dU02NXBvZ3BVV3laOTA3?=
 =?utf-8?B?TUk4emFjM3FnMjJiU2JGbXl6ejAzSGUrYlc4cVk4VU5MK29zNmFTUWIrdGlN?=
 =?utf-8?B?SWZ0TVFvYzg3UkduOXkySnIzTFlKWHFHckZlWDZPUWp6cTJIcnVXVlFzL2tT?=
 =?utf-8?B?ZWFjVHNzWExuYjBTY0Vock9BSmVNSS9QbjBZV1N0U3cwUXlzM1d3L3p2dVR0?=
 =?utf-8?B?MjJPOHQ1Y05zOFpkVWNobHRiZlBuRmgwY21LcEp1dEdCQ1d1WENrODkyYm5q?=
 =?utf-8?B?YlY1U1IwT2cvcUQrOGJ5NC9uK2NkZ2J4dFJHV2ZYZ2Rvakh3NGtVNkR5TG9T?=
 =?utf-8?B?dVNIbC9KMUluczlmR0JkQ0Z3d3AzYTVnOHRNQlRIMEgyZWhqOWlQUm5kWE1O?=
 =?utf-8?B?aEpSOVMvc3BsS2o5dkFJQzZGd21HSkQxMzFFNG9lNERwY0ozL1dPdTBGOEVi?=
 =?utf-8?B?VWdQOGVOWHZNcVlYbmMvOE9BZGZXa21YWWVNU3FnbXR6dnI5dGxFR2E1SGFU?=
 =?utf-8?B?ZUM1eDJMejI5SS9ncnhCNkJhY0NjRmhrNzhYM3ljbnZrdkdFUlpWS1A3a1Zw?=
 =?utf-8?B?NGh1MUtKdHBRblcwTXBMcW9ZQnR5SkNSNzlselU4R3ZYc1ZOZnEzN2VrTjlB?=
 =?utf-8?B?cjRMQlpqMkpYR0p1T1pCYXdrZDgwMWJqV2xROFFjbEJNUGtRb25ielJuWU9o?=
 =?utf-8?B?YkZaNEZaSFVCRytjRzFRYVJuM0E3MlhsazZoYW5WWFB5Y0tNaXgxS0RKVHBI?=
 =?utf-8?B?djI2VUlIbUpaWGZVVkwwSDliYzNoVC9tSThFc3p4UVVKZjBDRDR6UGE3Zy8x?=
 =?utf-8?B?dHRZYWpBL0l0dlV3Z2oxOFgzMnQ0aVBCdU1sdktBT1QrWGIrVnJKeEJLTXFh?=
 =?utf-8?B?ZlFaZ2JJbHBwdWZRTHA2UWt3Wlp6eGVCVnBsSkZPWDFwQXJWc0g5Q1l0aXpX?=
 =?utf-8?B?R1ZpdlhVaDlzQ083TENzTkdhUmptemxKbFp5TmhEOHFyeDkyczU1Q1hEQ05R?=
 =?utf-8?B?REtEb2dueko2M0oyNmUyQVdYbEh1dExJWGdpbW52cXFsMVR0U3hZYVk1d0k4?=
 =?utf-8?B?b3ZrMjNNM012czBSejRIWUtXeVRBU3ROdHF3Vk1DTlhVN2pmM1dOOExMWUJR?=
 =?utf-8?B?KzJjdzZOdUg3QUZlbjZ6OWxHcGVNZDBCdjhqWEg1clN2ZENpQzVQeENHZW10?=
 =?utf-8?B?bXNqVlpyVG9SbWRSRXhkYnhndFpyV002bEI1MWZORGVZcXRab3I5WXMxWnFW?=
 =?utf-8?B?RWNSRllSbzhSMElZdzZpSUQxMlJXcHVRZnZuWE1lWTNwNU1KYzl1NnkzTVdQ?=
 =?utf-8?B?OEhhM3BER0dVSG9WWjZUNnlTR2xwQmlXdTNtcURTQ01ab2xZc0RCV1dLdHhD?=
 =?utf-8?B?RHU5QnovZUxiLy9mQ093SGI0WE05NHhRTktrYnpkaUE3ODRsdFZtNk0zS0E4?=
 =?utf-8?B?RHN3OCtGZHptT3ExOEtXR0lyYXkzSzR0cUJuTC9xWVdDK0VaMGcxOXNJZ1k4?=
 =?utf-8?Q?d+U49P6zMHZttTj6j4Gz2uKeC?=
Content-ID: <DA3E566093525A498C8C07188424280A@namprd19.prod.outlook.com>
MIME-Version: 1.0
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-0: NYAtWK29opcI/L1DiaHvO0OW9Zx4+ps4roFG+47jOs8wUZ8vQ25FeWl9M38RqAHv+192nVdH3ItOk7WIXxNF1+1F9xPcn9FBUjJth+wjZJDOtAS26l7cDIKwu8LBxJgPaWRKb1qINOWbzq7xwAX/P6bXwIfutyAPopBMUzpRlZ1rbiZXDdVdJO8YHgs7SiYyqsMSjxiB+y/a4ljOszfcf83vARSPlaSnVWzYSIfybGEy3vrpKmz8k8wzTw/2S8M6CVLluQYYp6KdlkSqi14TQYn5H1qIllUJ5CSTRAn/yuPQgNglw3Ej9yovigJ7PNzL4tA86DMsfSVkaBQVUldtbFS5+mS3kXDrTz75mTjZtojh9ZXCXosjlI3NjMywy9VWuCRfkJZE5wF8WMwsVemlkgJpNbejEUpNvG6/mas85I4x1WIV+5yKjVryRW4/yINBJRuvol7faPu5cVLereR6yY5bOU+L8azMgkPR+n3eltAOHVq9yseLWYVfsZ/NDjucA1MSoXF02it0HpfrH/oiFn12rqoKwKdiBWFr3Ue67jXeNZziiQCJ52X8Pnhq25eYud1VBjy/3I46yt+7BMCG97QbOfTrvuP3QAHA5QYOvM9KAX7h3LIJK+pJv2WEIr7mkhu60no0ee74/ONSt79NzrpPVu8E8IRmf1/KtpZLzR8=
X-OriginatorOrg: whamcloud.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: SN7PR19MB6567.namprd19.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: cdb74614-1c79-4c08-4f8d-08dd448ae984
X-MS-Exchange-CrossTenant-originalarrivaltime: 03 Feb 2025 19:42:37.0072 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 753b6e26-6fd3-43e6-8248-3f1735d59bb4
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: 66PB+ixPFsYrB7n/+F8WrHwmd0IQqxXSDBxELAyx30AWlTK9tjX4S+YGC8XGzYP3
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN7PR19MB7042
X-BESS-ID: 1738611760-102623-7607-44855-1
X-BESS-VER: 2019.1_20250123.1616
X-BESS-Apparent-Source-IP: 104.47.58.176
X-BESS-Parts: H4sIAAAAAAACA4uuVkqtKFGyUioBkjpK+cVKVqYmBgZAVgZQ0CwpzczENCXVws
 LQ2Ngy2TQpySQt0dgk2TLVxNjUNNFcqTYWAGBosppBAAAA
X-BESS-Outbound-Spam-Score: 0.00
X-BESS-Outbound-Spam-Report: Code version 3.2,
 rules version 3.2.2.262266 [from 
 cloudscan11-8.us-east-2a.ess.aws.cudaops.com]
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
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

On Mon, 2025-02-03 at 17:24 +0000, Day, Timothy wrote:
> > If you want to avoid surprises for your patches, I can publish my
> > boilpot scripts and you can run your own instance if you have the
> > hardware.
> > Or we can find some sponsors to have some sort of a shared public
> > instance where people could drop their patches to?
> 
> If you could publish the boilpot scripts, I think that'd be super
> helpful.
> It'd be a lot easier to understand how to reproduce these failures.
> Plus, writing the orchestration to run it in the cloud would be
> straightforward, I think.

Unfortunately cloud is not very conductive to the way boilpot operates,
the whole idea is to instantiate a gazillion of virtual machines that
are run on a single physical host to overcommit the cpu (a lot!)

so I have this 2T RAM AMD box and I instantiate 240 virtual machines on
it, each gets 15G RAM and 15 CPU cores (this is the important part, if
you do not have cpu overcommit, nothing works)

inside based on the node id (hostnames are just numbered for
simplicity)one of several scripts is run:

LOCALNUM=$(basename $(hostname) .localnet | sed 's/^centos-//')


if [ $LOCALNUM -eq 300 ] ; then # impossible to hit
	FSTYPE=zfs
	MDSSIZE=600000
	MDSCOUNT=3
	OSTCOUNT=4

	export FSTYPE
	export MDSSIZE
	export MDSCOUNT
	export OSTCOUNT
	
	export ONLY=300
#	exec /etc/rc.d/tests-sanity
exit
fi

FSTYPE=ldiskfs
MDSSIZE=400000
MDSCOUNT=1
OSTCOUNT=4
# 50% probability - ZFS
test $((RANDOM % 2)) -eq 0 && FSTYPE=zfs MDSSIZE=600000

# 33% probability - DNE
test $((RANDOM % 3)) -eq 0 && MDSCOUNT=3

export FSTYPE
export MDSSIZE
export MDSCOUNT
export OSTCOUNT

#if [ $LOCALNUM -eq 100 ] ; then
#	exec /etc/rc.d/zfs-only-mount
#fi

case $((LOCALNUM % 5)) in

0) exec /etc/rc.d/tests-racer $LOCALNUM ;;
1) exec /etc/rc.d/tests-replay $LOCALNUM ;;
2) exec /etc/rc.d/tests-recovery $LOCALNUM ;;
3) exec /etc/rc.d/tests-sanity $LOCALNUM ;;
4) exec /etc/rc.d/tests-confsanity $LOCALNUM ;;

esac


and then each tests-* does what it says.

They all begin the same:
#!/bin/bash

. /etc/rc.d/tests-config
TESTDIR=${TESTDIR:-"/home/green/git/lustre-release/lustre/tests"}
cd "$TESTDIR"
while [ ! -e ../utils/mount.lustre ] ; do sleep 10 ; done

bash /etc/rc.d/tests-common &

and then split as below:

screen -d -m bash -c 'while :; do rm -rf /tmp/* ; TIMEST=$(date +'%s')
; SLOW=yes REFORMAT=yes DURATION=$((900*3)) PTLDEBUG="vfstrace rpctrace
dlmtrace neterror ha config ioctl super cache" DEBUG_SIZE=100 bash
racer.sh ; TIMEEN=$(date +'%s') ; if [ $((TIMEEN - TIMEST)) -le 60 ] ;
then echo Cycling too fast > /dev/kmsg ; echo c >/proc/sysrq-trigger ;
fi ; sh llmountcleanup.sh ; done'

screen -d -m bash -c 'while :; do rm -rf /tmp/* ; TIMEST=$(date +'%s')
; EXCEPT="51f 60a 101 200l 300k" SLOW=yes REFORMAT=yes bash sanity.sh ;
TIMEEN=$(date +'%s') ; if [ $((TIMEEN - TIMEST)) -le 60 ] ; then echo
Cycling too fast > /dev/kmsg ; echo c >/proc/sysrq-trigger ; fi ; bash
llmountcleanup.sh ; rm -rf /tmp/* ; SLOW=yes REFORMAT=yes bash
sanityn.sh ; bash llmountcleanup.sh ; SLOW=yes REFORMAT=yes bash
sanity-pfl.sh ; bash llmountcleanup.sh ; SLOW=yes REFORMAT=yes bash
sanity-flr.sh ; bash llmountcleanup.sh ; SLOW=yes REFORMAT=yes bash
sanity-dom.sh ; bash llmountcleanup.sh ; done'

screen -d -m bash -c 'while :; do rm -rf /tmp/* ; TIMEST=$(date +'%s')
; EXCEPT="32 36 67 76 78 102 69 106" SLOW=yes REFORMAT=yes bash conf-
sanity.sh ; TIMEEN=$(date +'%s') ; if [ $((TIMEEN - TIMEST)) -le 60 ] ;
then echo Cycling too fast > /dev/kmsg ; echo c >/proc/sysrq-trigger ;
fi ; bash llmountcleanup.sh ; for i in `seq 0 7` ; do losetup -d
/dev/loop$i ; done ; done'

screen -d -m bash -c 'while :; do rm -rf /tmp/* ; TIMEST=$(date +'%s')
; EXCEPT=101 SLOW=yes REFORMAT=yes bash recovery-small.sh ;
TIMEEN=$(date +'%s') ; if [ $((TIMEEN - TIMEST)) -le 60 ] ; then echo
Cycling too fast > /dev/kmsg ; echo c >/proc/sysrq-trigger ; fi ; bash
llmountcleanup.sh ; done'

screen -d -m bash -c 'while :; do rm -rf /tmp/* ; TIMEST=$(date +'%s')
; SLOW=yes REFORMAT=yes bash replay-single.sh ; TIMEEN=$(date +'%s') ;
if [ $((TIMEEN - TIMEST)) -le 60 ] ; then echo Cycling too fast >
/dev/kmsg ; echo c >/proc/sysrq-trigger ; fi ; bash llmountcleanup.sh ;
SLOW=yes REFORMAT=yes bash replay-ost-single.sh ; bash
llmountcleanup.sh ; SLOW=yes REFORMAT=yes bash replay-dual.sh ; bash
llmountcleanup.sh ; done'

The common scaffolding is to just catch stuck tests that have no
progress for too long:
# Seconds
TMOUT=3600
TMOUT_SHORT=2400 # 40 minutes - for ldiskfs
TMOUT_LONG=3600 # 60 minutes - for zfs
WDFILE=/tmp/watchdog.file
TOUTFILE=/tmp/test_output_file_rnd

# Initial rampup
sleep 10

while :; do
	touch ${WDFILE}
	sleep ${TMOUT}

	if [ -e ${WDFILE} ] ; then
		# Just a long test? Give it another try
		dmesg | grep 'DEBUG MARKER: ==' | tail -1 >
${TOUTFILE}_1
		if [ $FSTYPE = zfs ] ; then
			sleep ${TMOUT_LONG}
		else
			sleep ${TMOUT_SHORT}
		fi

		if [ -e ${TOUTFILE}_1 ] ; then
			dmesg | grep 'DEBUG MARKER: ==' | tail -1 >
${TOUTFILE}_2

			# If no subtest changed - force crash
			if cmp ${TOUTFILE}_1 ${TOUTFILE}_2 ; then
				
				# extra zfs debug
				if [ $FSTYPE = zfs ] ; then
					(echo "zpool stats on hang" ;
zpool iostat 1 10 ) >/dev/kmsg 2>&1
				fi

				# and crash
				echo c >/proc/sysrq-trigger
			fi

			# We only get here if the test was different
			# Since the progress is there - just keep
monitoring
		fi
	fi
done

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
