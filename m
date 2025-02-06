Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 92829C02194
	for <lustre-devel@archiver.kernel.org>; Thu,  6 Feb 2025 18:48:00 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4YpmLp34gGz1wMp;
	Thu, 06 Feb 2025 10:47:46 -0800 (PST)
Received: from outbound-ip168a.ess.barracuda.com
 (outbound-ip168a.ess.barracuda.com [209.222.82.36])
 (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4YpmLZ5HDLz1wMp
 for <lustre-devel@lists.lustre.org>; Thu, 06 Feb 2025 10:47:34 -0800 (PST)
Received: from NAM11-BN8-obe.outbound.protection.outlook.com
 (mail-bn8nam11lp2177.outbound.protection.outlook.com [104.47.58.177]) by
 mx-outbound-ea41-28.us-east-2c.ess.aws.cudaops.com (version=TLSv1.2
 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
 Thu, 06 Feb 2025 18:47:26 +0000
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=g/WnhdREYmd+XCbjwcu5OLNUFzuSTmVaTQaETPUICAS9mWXka390DM5GqSi87qhd6kklGQuypR+vTn9BwSSLxSF8Bih04oaQ/xZygIqk/4F7oc/OsE6+IB9dwYLED98RqWAtWbOXQ45adOCgnfKp1mlrDj1r3WIkwT3fBTRHnw3/TfoLgxGTdmqbbGZyd6++0PIqN6J4hZoGN/8PCdVcKnwfm9kd9lIbuL/abSDmB1WZ1gNh+lwiIe9PaoZr8RToro2AvqMI2y5gXOvfPitRCfuGjwqefOdwaPIwfXGdo1+tAZqMWt9w+z2Q+NksWIPxyD7xLKStF2wlNArkXky/VA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com; 
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=LyUMGntXnKRV2xnsQm4lzGNyMF6bBo5wykMTbtaO3yg=;
 b=K8+ee3P4HUut/1DqkN5E/P3ueGrzrz+vnHnwArutmWSpHZ9ryE9vFWCRGK09MIhAa/NpINIQpm6yU1GDbK1cNXGT03h1jB3LCjtvIjmHx7t6NN2TpwDCpQCBT04zefgy5FEey17lPhxIQDwoLKxuAgsNto/kQApKGg1Y8hynk1V8nY199fYz3gJ7DMC7tikG6eYEpSYwAmmUxnbdfDb/EjCyfw1qxejK0mER0HOpzKnOMwzl8JBEqnpgTGjgmYCEDB2WzW4VS5qy925NCcfMtUnxLtTxlPtBPq63xPBuEueYbTzZzWx74d1ojSL+XSHdaM+yu4sPeo505bOAgFTZ2Q==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=whamcloud.com; dmarc=pass action=none
 header.from=whamcloud.com; dkim=pass header.d=whamcloud.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=whamcloud.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=LyUMGntXnKRV2xnsQm4lzGNyMF6bBo5wykMTbtaO3yg=;
 b=ivUhFI3QMYwnRCs4bukntb1DEsRhGFGtvHhML7SvbP4yZH6ryR54XJ0UzvyJ78TwoQvo/2hB+rB0xpzh8fkAel4fcheB99Iw/aSVeptbnlgB5PI4kTsHItwqbmP1BNCkbrBw1A/rnsQp0y25VID5wo6WTg+oD3X3Wli2I73T/K4=
Received: from SN7PR19MB6567.namprd19.prod.outlook.com (2603:10b6:806:26d::11)
 by PH7PR19MB6087.namprd19.prod.outlook.com (2603:10b6:510:1de::10)
 with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.8422.10; Thu, 6 Feb
 2025 18:47:22 +0000
Received: from SN7PR19MB6567.namprd19.prod.outlook.com
 ([fe80::db50:586b:7dda:cf04]) by SN7PR19MB6567.namprd19.prod.outlook.com
 ([fe80::db50:586b:7dda:cf04%3]) with mapi id 15.20.8422.010; Thu, 6 Feb 2025
 18:47:22 +0000
From: Oleg Drokin <green@whamcloud.com>
To: "timday@amazon.com" <timday@amazon.com>, "neilb@suse.de" <neilb@suse.de>
CC: "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>
Thread-Topic: [lustre-devel] [LSF/MM/BPF TOPIC] [DRAFT] Lustre client
 upstreaming
Thread-Index: AQHbaF06daQEbe3e/kelMir67rT0hbMbs8GAgAAqWwCAAUdfgIABebkAgAf62QCAAH1kAIAMBm2AgAASkoCAAr/pAIAAJnkAgAAH54CAAAPkgIAElVoAgAAGaoA=
Date: Thu, 6 Feb 2025 18:47:22 +0000
Message-ID: <d7c9db4f12b966c209cb4940c2113a644f63be3a.camel@whamcloud.com>
References: <d008c14bba74e39999ae70af871740a5d0c5c6eb.camel@whamcloud.com>
 <173844834301.22054.134358817491003595@noble.neil.brown.name>
 <82e4528eb0f4961bdc6b065dfcabea03c1a9face.camel@whamcloud.com>
 <AFA09EE9-0679-4484-8571-F03F7DEE20EC@amazon.com>
 <3ce0efd54f2bf45e84882de0e1b469caf1f74397.camel@whamcloud.com>
 <6F2B1870-F031-429B-8257-730845B6E18F@amazon.com>
 <3285ff88995a57ec6c01917c608519c5a7d0f78c.camel@whamcloud.com>
 <0CA3103F-1578-4AE5-9260-E95ED38139DE@amazon.com>
In-Reply-To: <0CA3103F-1578-4AE5-9260-E95ED38139DE@amazon.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=whamcloud.com;
x-ms-publictraffictype: Email
x-ms-traffictypediagnostic: SN7PR19MB6567:EE_|PH7PR19MB6087:EE_
x-ms-office365-filtering-correlation-id: b9b09279-4f79-4193-0b8e-08dd46deb114
x-ms-exchange-senderadcheck: 1
x-ms-exchange-antispam-relay: 0
x-microsoft-antispam: BCL:0; ARA:13230040|376014|366016|1800799024|38070700018;
x-microsoft-antispam-message-info: =?utf-8?B?RTFlNDJob1FHbDBDekx2QlJuT3R0KzFhVkpzNHFnTzRpcDRubDdVcXRUV09v?=
 =?utf-8?B?N0h5aUZjeHh0dUN4L1IvSmp1QjlGYkRJOGdvdFpyMnpoYTBmcmgrRXZBZ0xN?=
 =?utf-8?B?S0VaNStPVU9vMjc0cDVNODRZM1daaTdMUjhMQTJ4WXJpTUZ3OHYwZkNHbWdw?=
 =?utf-8?B?M1dEOE5vYitKV3hsdWZOUEFvQ1VEb2FNMjJvRHFlRjQ4UGxBU05sdGlWMXpp?=
 =?utf-8?B?K0VwN1V5L08yQU5aVFI2RFBwK2hTS29NdlFmd3FIQ2tRakdVVUJCL1RxZ0Rq?=
 =?utf-8?B?UG5ZOXZjOHhIM1pDaXcrV3lJTmJaZDIzdDBsaTdBenN4Z2dCZzJpRjA5WW0r?=
 =?utf-8?B?ZXI1UXloeXZRL1VCU1doK3pwRWxGVmsvSGZXTVBPdy9DTDhPUUd5aTFuc0c0?=
 =?utf-8?B?NTN5SldtNUEwU3N1NytOWWlUNjhNdEhQL09UanZaQTFCMEZxOVFtM0NjcitV?=
 =?utf-8?B?TS9pU0xDYUI4RXEzZmVFMEJRUzI4UlF2d3VrL0V2aHh3Vzl1QXk1Z0ZheXpl?=
 =?utf-8?B?YVNwYVJzVjRveEJucVBXb3k1Q2tPeHF5c0hucGRnV2cwZlVjK2p4aTBqV0Ez?=
 =?utf-8?B?RUhiMzR4YWh5eFZyTUFIL1VSNjA1NXZSN1lUb0tGV3BKZnRpM2hoMzRBVVd2?=
 =?utf-8?B?dHlNKzQ5M3FZdlJxc25nSmNWTjErckpnb0V2bXpEZTh2anZXSjQ2eXRmN0pa?=
 =?utf-8?B?ckZQc0tkV0xkNlQ5ZXQ5V3VGZGw2YWMxNGtPay81MFkwNXdoOGlwTldDUWJw?=
 =?utf-8?B?aE11dk5kTHdaRVRUNDRjTnQydDRhL0NWUU9MQUZhNG9XTGpmK1JZanM4U25Z?=
 =?utf-8?B?b3p2M0dzVDFOVUo3L3B3Wk50K0RVakRPb1lDL1JXNG5NKzhPRVZoQTFWWDY5?=
 =?utf-8?B?RUp5TUZGRSsrbXB6V2JvTEFqbUl0RlJ2c29iMjZNdUtzdTJ2K042NTJOeGdN?=
 =?utf-8?B?V1hhaVBnV3ZJZm9wM2R6b3pZUVlPRityaHdZUkhQbzdWcEdFWWRlb3N5eU9U?=
 =?utf-8?B?MXRWQWZxRExkc3NtRU5pK3VCVjQ4QWIyQWN3Mi9lYk1sTnBSZkZnbmcwSWti?=
 =?utf-8?B?OXZBYWEwaU1YREx3NHZHOE1tbTVrbS9rUElMdDNRbkltTlFaekh6SHFyWkdn?=
 =?utf-8?B?b2VDWVRrMnhFY2FQTXRXNFNCU0syY2RJM1lvVnRJNUplbjFTT3JMV0VPQk5x?=
 =?utf-8?B?Tnc1N0ZTeiszNHRSTW8zNUZXMVE5aFNiaHNTeVBHMElWZEJJUkZMR0pVYTNP?=
 =?utf-8?B?MDllcnRNWVk5THVBdjh5dDE3SlkzWEhPSGFtVmo3bVF3QWpibHVab0RpK0I1?=
 =?utf-8?B?Yml5YzcxazhvMXBnS2JBdmlCU0R5cjZtWG5CUno1ZUVtZEpWMDE4SlplbVVN?=
 =?utf-8?B?dVQweWVxS2V2a3kwd1ZiSzcvdUZwcm9Zc05zOEF4STNMb1dBazVzaUU4a3ZN?=
 =?utf-8?B?dlBlMlJXWDFmaFdrR2JyVUNOYmppNkM1NjJrQmRWUmsyNHZHd1dXS2Q4WkIz?=
 =?utf-8?B?RnJEME9vcDZsK1hIUDE2SDVFR29rYzFUa3NsbTRqOVBkV00wbmVVWElab1hD?=
 =?utf-8?B?aE9LcG4rdVFJb1dqSy94aHBnY29VUjdsNTlKa2xTR2ROOW1QU2FtWDErNStF?=
 =?utf-8?B?RVlRcDJLVzROUWtUOS83STZ2TkZ2QlpSWFgwclIxamk0ejJpaHh3QVhrWDEr?=
 =?utf-8?B?bS9RTVpLS0dHWGxvenhRTklpQzlJS0J1cEtZN2RTV3ZQL0tuMUFlYlQyOVlJ?=
 =?utf-8?B?NWt1QUh2SjRhY3ZVYnlMYTJtVjFZUzM4MTQwQTJLcllDVlUxT1dYQU9wZHAv?=
 =?utf-8?B?QU15amFaZ3hVOWpRMU5DSE1YZ1RxWGN3MXlZeDBYa093S0JMUWRCVVlOT0pZ?=
 =?utf-8?B?Z2VoSEc1YVJmVVdOS0pIZnZycHFsVUtSYnFzMkFQcEZ6cFE9PQ==?=
x-forefront-antispam-report: CIP:255.255.255.255; CTRY:; LANG:en; SCL:1; SRV:;
 IPV:NLI; SFV:NSPM; H:SN7PR19MB6567.namprd19.prod.outlook.com; PTR:; CAT:NONE;
 SFS:(13230040)(376014)(366016)(1800799024)(38070700018); DIR:OUT; SFP:1102; 
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0: =?utf-8?B?SFl6ZCtmTGxPYUlmV09xNWJqTTFDOVk2VnJ0bEpsQ29sV3J5UWF1YjVHeDdF?=
 =?utf-8?B?Y05ZVFVoWUdzeHBWVGRmbU5DaDhaV1dEdWdvVG5pMHpXWWVpbVBYcWh2aXlX?=
 =?utf-8?B?akpPenlhdXp3UHRCRjExK283V0lBUGFrZG1aRyt1VS9EOGNpN01jZ2tKaU9J?=
 =?utf-8?B?b0xsQ0lJZnVaTUJBcVpYZHBVa3Y3dDF0VEl2TnA4L3hZb01rRGJpUGQ1dzBt?=
 =?utf-8?B?OFR2MDdUQ0dtVjh4MkJiUWx5dm9CdmxKbDV2Wm1DbXFTY21JQ1cyUk1aa0Ix?=
 =?utf-8?B?STNBZWRDNWJSN2pxOVhQU1NhVGk4SWVqZnZ1Q2xrUTJGaE8rOGxiVGxOVlIx?=
 =?utf-8?B?V25SQlcvWG1kcnd4U2k5N29aWnR0NUlJeHpnV2puc0dEMUpZRnBkcnBRbk1V?=
 =?utf-8?B?NjkrMTRVYjdCQklodWxiMGJUandaazNqL21MK09INDV4bmdka2hzc29HUEk1?=
 =?utf-8?B?OHFNQWJZY1AybUNSamNTeFFyTU1mS1JybGZBNDJKN1B4WWx3S09YZnJiRG1v?=
 =?utf-8?B?c1cvbGhveVZpNVdGd3crQWMzOFl3L2RVaDNtbDJaKzJaQmFJb09Gc00wbHpF?=
 =?utf-8?B?Q0pYc2FJTSs1VjNDdXlHVHVtMEo2TVhVV1dTMGdKYzcwdE1SRldVQ2JIeVlk?=
 =?utf-8?B?aDI2a3VZVjFVWDZxWHlUbTRRQlBrNkRSeTBnUlFxWjRNeEt3NzR5dzFzWnFv?=
 =?utf-8?B?RlIzUmowZTNMSld5d0xHdHMxSjFKZS9NVzMxSHQrOFNkbGd3NUFqelk1SDUx?=
 =?utf-8?B?ZmxVSmh2SFhTWkRFMjg2Y2kxS29yeTUwVVA2RWVGcXh5dTh2eUh0UzdralRl?=
 =?utf-8?B?YkppM3VXUkdHZTNPUnNpeU1uTU4xRHZ6MkpUWmxUdzZqdS9WWXNGRnIyaFhl?=
 =?utf-8?B?SDVCVTd4UU15c3Y5UkMyWmFjdEhodUgrN1RlWHhHc1dEd2lBNllSdFBZL1kw?=
 =?utf-8?B?eTlaVnBhS2pQcTdOVnNkdHJNcVovcEo2Wko3MVYyT3hMbXJSVkRTYk1XNGh6?=
 =?utf-8?B?Wmo5VzJuTVVYNjQxSlYyeDdWT0YySm5pS25WUUYxcU4wL1ZaSkxVaSsvOTNY?=
 =?utf-8?B?dGtQb0RkUTJpVmdGbktjRDhSV3o0bnVvZnNzNHZPL2djWHhCakl4T3c1M3Jo?=
 =?utf-8?B?dlVsU3ZZSzBzRTMwZ3A2WUtOMG9YelRpK3p3VWNYalpsSWRqc3lQOUZoWGtH?=
 =?utf-8?B?eTdLanVKYmZ1UlNRT2R3NUVOcmc3VDh3ZEZJUEdTNCszNWNtbjF0aVFQUk5r?=
 =?utf-8?B?QWU2eHhCdTMvOU91QjEzZFZDWmkvZjFDU29mUEJaQWtLL0VZaG5lOEl6RTZx?=
 =?utf-8?B?ZUFhcWtpc2dldmJEYnBMSzZubk82My94cDN6dHFCVVd4K21ma2xMeHl1ZWl0?=
 =?utf-8?B?bWEyckMyUytCM2RVNFZHaVA1Nkh6ck1ZT2xJZjZYK252T0pUQ1dGVUVJS2cr?=
 =?utf-8?B?SFNScXJrMTc5Y05oWlZKd2dZREJIU1BVODEvQTlyUWxFKzllekpKYnZtMHlh?=
 =?utf-8?B?RmhZY1lWdUlGM20yZ2wwLzd5Yk9oSzJ6NmFwUWFiWVROTGtrUFBneWtqMnVm?=
 =?utf-8?B?eEZ5d1JPWklXYzZ5M2J4ekVPS2lYbzNZUENtOXdYcTZCOHFTRVhQT1E3Rmho?=
 =?utf-8?B?OUlnTXR2Z2xCWHNsVHl3Tys0a0xUZVBOU1cxMnBWOERkY3lPUlZsNXM4WWtn?=
 =?utf-8?B?TGRMMWszWjhHd1pzZ2gybCtsVkUyallkSlBEczVQN3BrZVpZS2swNnphNjF4?=
 =?utf-8?B?WTZ1WGE5YUFmaWVodlF0L1dNcVdaS0drU295blcvVHh2WGRIM1dPWHhHMXRp?=
 =?utf-8?B?ZDlUcjNUQmsxRisyVDRPY2EzTFlMVnIvQVhveVRpMVBaeUxZWXdaZGVTTS81?=
 =?utf-8?B?NVYyY0ZKNmNWbkwrK0w2Z3ZTUkQ0OHJ5VERWQm9GMHdKL1hzaXJuTFo3OU9M?=
 =?utf-8?B?VUlZMXZRVEhJM2NxZ2lwRGNmODZCcHVhdjdzdlk5NmdRUm56VkM0VXhyZC9L?=
 =?utf-8?B?eFg0WjFsdmpjTThPZXVRN1NsZHF2ZytjWjcxOE50djZTUFJ0bUpOYXhPTHNY?=
 =?utf-8?B?TWFUMTdvV1RkbWc2TVZUOWFXTmZoOHpmVFg2a3Z6K0h4L0FXQTdyUlcvcGM2?=
 =?utf-8?Q?ma2c/8l8HvjzZdlxqPIwnipiH?=
Content-ID: <67ECCC986E45B941B92C4E624B2819FC@namprd19.prod.outlook.com>
MIME-Version: 1.0
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-0: 6oIX1FNtWMoxOj0UpZRHOfuEe96YyBiiunNyihHjD4GV+s91I3TjNPwH86Ohdwkp1iMykiMO1vzSMoWjOI4zqTmmYg3C6c4KT42uGXIYfoOULd7P2PETh+N90bF/KD++fuKbGjZWvE8FKtcGSZsEohdMNfhJNfQ34nX+vmm6JeTgF/0QyJ11V5vEWC0TG7RPnp3ejk0/AWSSu+gMqOSXAg+S6rkalNvlW8tZJLS1u+ckTDQ4NMdQzsRG6WTaSEKAiMd65NepjYqKnj0GNnakY2WZ9zBbiqNPrTVH0H92TXXqna+Z6lXtFkSurmsX7JcKAOY8J/OcC7nVeWkbICYtWFQ6dsuBqcMgO68oIu1P3KpRpBYEmv/bBl+sp2fohCcNY2gsKV5gw77n9tgyuhqCovcjfNsq62XNMnk8h1+wcKc52gYyZim1m/YF6qZBBekDJX39SXXis9FtcaEQB1b+9UrNnPji2ImIoFzxhmG6BeUJgpHhZap4hrhRqyCBeOZzUNbVOWfiKz4tEUJnw1CyuZDVAPjcp41WUMDOtssAPOv2jK0N3Qq8BVuKztOhSGNwZoZnnwAwV2GF6VEx7Zla3oHizB3Yo4lVfTSUvUsc8bZE9e3Muk+acKFK99Unj0A+LckLNW42oXSEnttg3lzygpr9/MxX2c1tpnJH/qpFWRk=
X-OriginatorOrg: whamcloud.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: SN7PR19MB6567.namprd19.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: b9b09279-4f79-4193-0b8e-08dd46deb114
X-MS-Exchange-CrossTenant-originalarrivaltime: 06 Feb 2025 18:47:22.3800 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 753b6e26-6fd3-43e6-8248-3f1735d59bb4
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: QyZszzvaOnNsMpix3A2+fiNY3cnvLegncZ7XZh19o6H7j/V7quhABYNFHoAjMGfe
X-MS-Exchange-Transport-CrossTenantHeadersStamped: PH7PR19MB6087
X-BESS-ID: 1738867646-110524-1859-25828-1
X-BESS-VER: 2019.3_20250205.2219
X-BESS-Apparent-Source-IP: 104.47.58.177
X-BESS-Parts: H4sIAAAAAAACA4uuVkqtKFGyUioBkjpK+cVKVkbGJmZAVgZQ0CTJ2MgsOdnQ0i
 Q5OdHcxMDS0NjA0NTY2NDCyNLMMNVcqTYWAEQR9QRBAAAA
X-BESS-Outbound-Spam-Score: 0.00
X-BESS-Outbound-Spam-Report: Code version 3.2,
 rules version 3.2.2.262335 [from 
 cloudscan8-156.us-east-2a.ess.aws.cudaops.com]
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

On Thu, 2025-02-06 at 18:24 +0000, Day, Timothy wrote:
> 
> I wrote a parallel ktest runner [1] a while back that probably does
> the needed orchestration on the host side. It was originally intended
> to run sanity tests faster (mostly for the OSD stuff I was working
> on).
> But I think it could be adapted to run boilpot without much work.
> It'd probably need some daemonize mode and I'd need to validate
> that ktest actually captures all of the error modes we care about.

Aha, thanks, I'll try to look into that.

> 
> Ideally, the boilpot part would be platform agnostic. The cloud
> orchestration part would just create the VM, run boilpot, and shuffle
> the crash dumps off the box. My main goal (right now) is to get

In fact I ppre-process crashdumps on the boilpot and then feed a server
with that data and if the crash is deemed "new" or interesting enough
for other reason it wil lrequest more data that hte boilpot will then
provide.
After all there's only so many identical known crashes one needs to
store.
 
> something easily reproducible and get a sense of the signal/noise
> ratio on boilpot. Plus, it might be interesting to try and flush out
> bugs

After I filter for all the known and "invalid" failures I get probably
on the order of mat be 1 crash a day, sometimes less, sometimes more.
Last one out of current master-next came totally unknown:

https://knox.linuxhacker.ru/crashdb_ui_external.py.cgi?newid=72768

This allows much higher visibility when something breaks, so with the
recent https://review.whamcloud.com/c/fs/lustre-release/+/55724 all the
procfs failures were really visible (and when I changed the recovery-
small to only run tests 55, 56 and 57 - the frequency shot up to
several crashes every other hour).

You can also see time-sorted crashes from all sources that report to my
server here: https://knox.linuxhacker.ru/crashdb_ui_external.py.cgi

(add ?count=XXX if you want more than the default number. It only shows
"unvetted" crashes too, which is something I probably need to change
eventually, but those are the most important ones I guess)

> in my OSD as well [2]. It's hard to say how often I'd run it without
> first seeing how effective it is.
> 
> Tim Day
> 
> [1] https://github.com/tim-day-387/ktest/tree/pktest
> [2] https://review.whamcloud.com/c/fs/lustre-release/+/55594
> 
> 

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
