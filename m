Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id AB311C83F03
	for <lustre-devel@archiver.kernel.org>; Fri,  4 Jul 2025 08:15:09 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4bYRJW5K3Nz1x3l;
	Fri, 04 Jul 2025 01:15:07 -0700 (PDT)
Received: from outbound-ip168a.ess.barracuda.com
 (outbound-ip168a.ess.barracuda.com [209.222.82.36])
 (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4bYRJJ3TPVz1wVt
 for <lustre-devel@lists.lustre.org>; Fri, 04 Jul 2025 01:14:56 -0700 (PDT)
Received: from NAM11-CO1-obe.outbound.protection.outlook.com
 (mail-co1nam11on2090.outbound.protection.outlook.com [40.107.220.90]) by
 mx-outbound14-249.us-east-2a.ess.aws.cudaops.com (version=TLSv1.2
 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
 Fri, 04 Jul 2025 08:14:17 +0000
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=ti0qwMH9xIa16KPjebWy9zr4NnzXNYydAMlWqqU6cC2DHiRWKoqdH4WY7r+MhsYxDqFu3XJuVQikOrS+9Lu+GxcsDD3lWtg5pTWKdG+TTAtGXiLFsMfQJ46CuUqWa6kBJfOZgPiFq0PxKkZwS2ugRkuDyoffqhrpNOGxQbSbm0m1MPOgLAog3lOoXtp66I6JcvF8OYALShdVH65T3u9fWOQpG8GwxZmzZae1mU9SErtamKl8ebC2PmoGKbcxAEGJeEjlITXlN0cW5eQhdo11eSf2y2Y+nm5tam0tDzECFfrDOLDGtfuYQ+/4feIYrh18aR4sW4v3AmpDeU2uXISBQQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com; 
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=mVoZVK6RCr9GAhB9/GOiWsYdzUL2V/vFML32asrTIQY=;
 b=zHcuAtmrhvN/MA++a9XDxu1U1ZL1nQjzgZeLnexc2MtbSpixshDQJ137kZoHFfKEhw6kgifqErCX57atdeLt/21c9XMBDIy9qa9K5bY88VYJZ4zX7Wf/Yi7OgRpQ6s0g3lI8xdRm6wMeehNptL3H/cAleECFKxUNUC5jXKGhv9CB5LtUttUu+9phz6PNXe07kmiotrGLOqFNrAlctPsYEnSJGx7Ec0/k6tnaaMdWXJIRpgn7qPEnsnLoealxBWfBNU+vWijYqf0p+DIl4Poo2hggx/Sv1sV2jj7MLjQNr/qmJ+tIDadnEV2w8Zuc8PKOsA7PCsAWzVdRO4CgVqCFiQ==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=ddn.com; dmarc=pass action=none header.from=ddn.com; dkim=pass
 header.d=ddn.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ddn.com; s=selector2; 
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=mVoZVK6RCr9GAhB9/GOiWsYdzUL2V/vFML32asrTIQY=;
 b=efAIQTU5ldt1ykVbk+x50VRSm7gsjzNSqHTVb3HGN8qCFqrxNj9HuSVJaj8NoboxzKzpf7DlQWNPdJJjUpf1rpRzRtd6Fr2t/6nFwuSjQ3WDpCCv4xnrjOttzoWq9rjN3A2pZaMcIwLx1/qLyxHIy5QLLSzuYPXkOpW+AhiUxx8=
Received: from MW4PR19MB5630.namprd19.prod.outlook.com (2603:10b6:303:189::12)
 by IA1PR19MB7208.namprd19.prod.outlook.com (2603:10b6:208:42c::5)
 with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.8901.19; Fri, 4 Jul
 2025 08:14:14 +0000
Received: from MW4PR19MB5630.namprd19.prod.outlook.com
 ([fe80::e1df:47f8:9e7b:c4ea]) by MW4PR19MB5630.namprd19.prod.outlook.com
 ([fe80::e1df:47f8:9e7b:c4ea%6]) with mapi id 15.20.8901.021; Fri, 4 Jul 2025
 08:14:14 +0000
To: Xose Vazquez Perez <xose.vazquez@gmail.com>
Thread-Topic: [lustre-devel] [PATCH 1/2] lustre: refresh FSF licences
Thread-Index: AQHb4h21TfT3xO379kaRHzuNDN0DIbQMO76AgAWrdYCAAHGlAIAACRQAgAHBMACAAAn0AIAARj2AgAATIgCAC71qAIABbxwA
Date: Fri, 4 Jul 2025 08:14:13 +0000
Message-ID: <5B24E525-8D58-487F-8907-63601C7B5F51@ddn.com>
References: <e0dac4da-8b43-4592-a282-6b9f84facbc5@gmail.com>
In-Reply-To: <e0dac4da-8b43-4592-a282-6b9f84facbc5@gmail.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=ddn.com;
x-ms-publictraffictype: Email
x-ms-traffictypediagnostic: MW4PR19MB5630:EE_|IA1PR19MB7208:EE_
x-ms-office365-filtering-correlation-id: 15824a8a-a016-4f2c-8194-08ddbad2c359
x-ms-exchange-senderadcheck: 1
x-ms-exchange-antispam-relay: 0
x-microsoft-antispam: BCL:0;
 ARA:13230040|1800799024|366016|19092799006|10070799003|376014|38070700018; 
x-microsoft-antispam-message-info: =?utf-8?B?a1dkUFFCSStwS2hjd21TaXRQM1F4eVl3M3BSQkNWNzZLVmZiN3RjeWkxeDhn?=
 =?utf-8?B?MFFmRGF2YThzektrRGtCYytIMFFhckJqUkZTbG9CbDZDRDFiWG5uU0tVb1JS?=
 =?utf-8?B?WS9TeHgyUGhQQ2FNNlY3Vk5xRmxOWEJ2bWlzaDMvWVpubjlDRzRZU1grZ2lK?=
 =?utf-8?B?QVJjb3JiU2YxTDRkUDBmQVltU2hnR0JvOFlPMEF3ak9rUXpmTHoxenFkajVx?=
 =?utf-8?B?bHFBTWlzNmdIMzhlSVV5UmM0RUpqUm9FY3RRSFdta1hiMXpGeVgyRFloZUV0?=
 =?utf-8?B?ZVo4K1kyZFoxb3ZQM2NxZW84RHoxNENUcUhBQVBzTVZ1c1hhRDNwRWFSMFQx?=
 =?utf-8?B?UmxIeStjQXJsQVFqRkFiTmJ3TTl4cTNSV2xqMXdwWWhKK21mQnovRkg2cU9k?=
 =?utf-8?B?ZmdQOEVQRWJ6MzJIS2FMNnM0YkV6dDlvRmplQXJwNWlqamRJSndkRXNZSmZx?=
 =?utf-8?B?TTBTN3RzcHFBZEoyZnRJRVRUUGQ5ZHR0YWlLc00xVWlTb2s2NkhhL1BJZ3Bs?=
 =?utf-8?B?bWZTR1NzWDBzV1dVaUhKK3FIOTBKZzRkVjRyeFBvUFAzMXlDU29EdGtFbVNY?=
 =?utf-8?B?dXdYL0FCUExMV2poVkZUazVoKzNJL01wKzQreTV0NmIwNjkvcmVXWlc1bVBY?=
 =?utf-8?B?ZDBCeE5UTzNjVDhSUHFsSEVlSUFONXBYWllUUE9mcGJTd3gwZ1QxbEtPUklH?=
 =?utf-8?B?N2V0MUhVdU1ibnBVUGsvK1ZFeUFzSkx4azR1SzNOdVdRUU1pcnFKMWo4ZUlJ?=
 =?utf-8?B?SFNxYklPNXlnWVhHbDRkaDhscGFYYmxFK1hxcjF4dVpUdDVoMlVOWmExQ2tE?=
 =?utf-8?B?UWJkT0o0OEtncWF3cGZzbmQ1dUU2ZVhyUlpIZnVCblNRK3k3WEkrWVhPYjNT?=
 =?utf-8?B?b1djYmlPVVdMR3p5VjRZcUFZV0U4LzRhY1oxNE9kLy9qVHI0cmJhNGpKcmNT?=
 =?utf-8?B?T0JBdW96Vno0T2Y4Rm5TOXVVcHdIOEF0RlBOZVg1UVVKNTU4Q3cyWU9rQWFs?=
 =?utf-8?B?aWg2N1BseFRJc0IrQnhyMjQ0bmRENVdVUkltUEhRem1UbEMzMnFvZlRpNjBK?=
 =?utf-8?B?SEoyOVhycklySXc4RnlmVjI2MVc0emFsQjRRa2ZwYjVKRzJ3b2pHSkw1QWxP?=
 =?utf-8?B?S0d4R2t4SEtTZXE0NFUxOG5BZzczNE1PclYzMEwrNjN5VkZvL1IvMnBuQUht?=
 =?utf-8?B?eWdKTVBBTUZLaHJyM2FpYitid2psUWp1QXF6RW5FMDg0czRnUFJrTTA1cTds?=
 =?utf-8?B?K3RmRDBIVXlzclJxajBZV0RLR0thaUxuS1hDOW9RT01yTVFHYmtLbGxJWHRT?=
 =?utf-8?B?OWRwb3FhcGRNN3FLV3RqZ05abnUyK2tVS21UZmhWVVJQSGMxWFNIa1pYWk1O?=
 =?utf-8?B?dnM4NzdCOUx1N0VoSkhRUzZFcnR5cHl2VFA5SXYzTVNoaExpbllpdVlqQWlZ?=
 =?utf-8?B?MFhkenZhRFV6L2pPS1JoRXJwY011ekd6S0NmQVIzTVhvMUhVQlF1dEJlRGNw?=
 =?utf-8?B?d29PaVNOOGg1MVZxTHczK3dscUlTRTZicjRIclprd2NDZy8zSmV0RHN2MXAr?=
 =?utf-8?B?a1luRjE1U2RXdk51RFBkV0ZjNnYzQkpWeW8zcG56ZUs4WWxtNmVEMy81Y0ZS?=
 =?utf-8?B?a0RMOTFoOVNPbnhGUmhXc1RXU3lEc1lCclJTSTdZUFg5RmZPUjJVV24zUnVX?=
 =?utf-8?B?Rlg0U3B4RFdhMnlIZHUySHJnWUY0V1BHcXBoRFRGdGlFZGtnb0JVZTVUMTJN?=
 =?utf-8?B?dS9RRVFLYzRIVENRODU5TXFqbW9rTys1WDdrdzVTSGhIQklCRGh2OXVsWjJQ?=
 =?utf-8?B?VW1ZK2NwMEZjSkRhWm9rWDIwMnZaN3hjMW5WMmZIRVBmZ3dCQW0wVGhKWllY?=
 =?utf-8?B?YmozNGlBcDkxcW12TUF0bnZsaitMVzFhZWJtZXVRSldheDBaTXZkV1NRbFZt?=
 =?utf-8?Q?3xnz5Lk0uKo=3D?=
x-forefront-antispam-report: CIP:255.255.255.255; CTRY:; LANG:en; SCL:1; SRV:;
 IPV:NLI; SFV:NSPM; H:MW4PR19MB5630.namprd19.prod.outlook.com; PTR:; CAT:NONE;
 SFS:(13230040)(1800799024)(366016)(19092799006)(10070799003)(376014)(38070700018);
 DIR:OUT; SFP:1102; 
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0: =?utf-8?B?Um9icjJvZjdQaThWMnFGclFxd2RKKzRKT3ZhVWRHTnZ0Rm5oNFRWL0Z3ckdX?=
 =?utf-8?B?VzdZZTUzYmp4SGpGMnpraG1yeEFHQ1puQU5CVnhRUVd6Vm9qSlFkci8zelgy?=
 =?utf-8?B?eDlhNXpOLzdNZmtrYXF0WXBqbHg0c2VOUmZRVElQLzA1YmZRS3RvZXphWCtB?=
 =?utf-8?B?MFE5RnhWMi83SVR4eStXNGVjQVNYWEg3RGcyaU5aRnQvb05oVDVCb241NlNs?=
 =?utf-8?B?Szc1TllROTZCSXFDU0R6ZmNROGt3VGxPazcrckRueXkvQkJEMnVaRDBlVUdY?=
 =?utf-8?B?ZjRXb2hWejRDVURGdVMxYmlLcm5vVGZWTWJiYXdYc3NMVnlZdWhjNmhudDdp?=
 =?utf-8?B?QW40UnNQOFpaN3RhTGUwUWdEZVdra01hQ3BjbXIwVy82WjlObVhhdVhMMVd0?=
 =?utf-8?B?QXdFL3dWUEh1RlJOeU5neHVZazRDMEFvazEzLzc2R1NVVWNIYjVTZGlsMHFv?=
 =?utf-8?B?SXBhZ2hlc0NTam9uRld6aG15VG9HR0MweEFxbitRUmYvT2QzUE1CRXBpcXp0?=
 =?utf-8?B?cHI4bjhLRGRNWUl6VGJGL3VhSCtkOVhldllRdzI3Ymo5SzRGUFFiODloMnU0?=
 =?utf-8?B?UndjeWMyeHNRWmxsWEwrNHpvTURiTU9wdGVhZE01MFNrQ3M4dWR3TGxWL1g1?=
 =?utf-8?B?ZlBQSXd5N0FkU3FTaEFFamV1RDRLTWs3eW9LeGpwNVZDM080VndENlRtaXlW?=
 =?utf-8?B?Y2JkV3pZUEQ0Y2RXbjV5UTFYZmh1djlYM3hsSDFOdVRMRk1YMFZGaHdDV0tQ?=
 =?utf-8?B?SS8rM3pCMEo5RTdMU3RWcis5QzJ6cFF3WHJJVEF0SWZhZ2hxOHRpVHMrVmlH?=
 =?utf-8?B?VmRyL3hRbHpncE1QRHd1Q3Bkd2ZWQkFqSEM2SU5paWhuQlZSdTJaYVhUUVpl?=
 =?utf-8?B?U0czM1lHS3ltU0NQc0hpMjErUERLVVY0Z0lMZlJmMzc3S29tZ00ySjk1T3pE?=
 =?utf-8?B?K2drR3lucysyOG1uQUxwNXUyQ1Zxdkg0T1c0dGh1Zk1XRCtMMDdkRVNIYTNK?=
 =?utf-8?B?MEhFUHZ3eFZWUDlvOUo4RUxudUNKeEhwOVhzS2RlTFkvT1I2dFRlTVJIVEFP?=
 =?utf-8?B?UTdGUzA0MldaMmwwdHJtZnVGMjZPWXp5V2d3QzNpWWZKSUIyMHpsMVc1c3Qw?=
 =?utf-8?B?RlFsTTlUQ2ZEZGVGQlBtY3RnYzh5cmxOdDdIZXdwdXEzL2JNWnEvNTBhZ3do?=
 =?utf-8?B?TDh0eXh0bHpvSTZkeXE3MWkxZ1JEL0l2VXN1RkwwSkpORlozTW0vR3l2OUQz?=
 =?utf-8?B?TkFrb1doSlAxaGl0Vmd2RmhTcEsreisxcXBVelNWL05hdlI1OVZhQ29hSW5s?=
 =?utf-8?B?NmRMMzN0V29CZDJSdWMzbjUvc041anJOQlFLTVE3djhVeHp0NkxnZ3RCOWlP?=
 =?utf-8?B?RTgwUCtzelpoSXgrSDgrTUtDYmUrSGgreVhPWS95SUwvK1E4bEpJVlEza0t4?=
 =?utf-8?B?NlFLbEtSRGNUT0dYQjduS0lRRE1laGpCTUFnb3l0MitXR3NtenRDdS9KM2FZ?=
 =?utf-8?B?TktGWUdEK0EvS0k1bDVxZ2orU05tTTNmeXNHSFl1d0FraTFFcHFjeE8yTVpU?=
 =?utf-8?B?RVhRdmVrTVhzVGEzbXZOTGpsMmFLZjBnREVhajd3YjllSzV5RmhFTXhsT2dn?=
 =?utf-8?B?SzhCQStNaEF6TE1hSXVHeDNQRU1SbFFtcWNkSW1GY2RjaWRFSUMrTXNuVzY1?=
 =?utf-8?B?d3FMNUlVcU5yU2ExWFI4d2MrUkMwWHNBWU9nOFRqbUhKRGpNU1FkRGM1R0Yy?=
 =?utf-8?B?RjlEQ3c5cTkvall5STBFalBwVnZIOHRhNnh2R3hoWC9LZmd4TkVNUWVFbXN4?=
 =?utf-8?B?N25KMHF6Yk90Ynp5Q3JScTNMWVNDRXJqRWdEQkhyMmVwOC9TckI2SmI2TEMw?=
 =?utf-8?B?WFNrV1EzYUlVMkdON01kcTdOdFd6ODVVNVVqQnk1dDhkOC9xUnU0dzQ0SnlL?=
 =?utf-8?B?WHZlVERKdkVVNWt6SmRKeDZIbDFwdGR3WFBUNzdDamJKdEZBZ0ZNaUlWc21L?=
 =?utf-8?B?bkRQbFRZYjhEUnJGR1VZM053c0ZRTzlCVEpWOTVyUnJSUWNBZDkxUEpac0p5?=
 =?utf-8?B?cDlxUldWMXk4SWxOb3o2dTNwV3pWOFo2elBDZWVsdTd5djRBTloya0NVNEhZ?=
 =?utf-8?B?V04rZHNtRUx6QmwxTXViQmwzMzJtNmoxcHFaa29lYkdPbXowMFJkVTZsMUVx?=
 =?utf-8?Q?5n6aFbRh99OamEXg9SyiWYnfP2W7vXIurNSQye89t5iY?=
Content-ID: <D15A12B3ED4E794DB5B58098482321EA@teamddn.com>
MIME-Version: 1.0
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-0: MXBgy6n0qz4Ufh17Ru42j+kkRKkAmot6pK7H5F/Ow0V3zVNVj3Y2SDuGoLZEobd/mRK6GkSbRemnNhfuFJE+n7c63enJewJHFNRIEv4E1FVM2rKZWJqkPjQnOyd4HVqfjmTTwGk+K/Rmi/6Ca0a48YYr4NgWtqwz/8m8VSL2oGml9yCDMwC2FGmbRIJSjHIHCNDcsh0lxITYK7rpEJmUOpi7Xf9tkJb65zPxP1JO4CMvVxv7ZaFHipCpK36WIESyMK1pAIXo/5czIMrVvn2FrH9SsDjZ4Gsqow9kFg9jCfnRxRp3bj6aEVlglSwBysFODDoTUJdjqoS3N1NGJ46CH76cDdSGwcPxzQaZGXYBLs6vPwIghGBQYaKNZE11gfIXBXDn5APYieMEkRFPtpwFsLp6GIZVSMDkc6h4m8fGSNC/t2o1+ZMlrfaBOmVAmttzqDMUJ0VSPrPV/VhgTGq4vJhvUi2M4ATBzlrzU3Lt4wXjrd2cRN3TOhKOsEKGdqIylDGDhdLOORw373sNLmPBkwYmBJR2bwdrA4Bbd8xBh5F4PM5zDK+gjOjbsmj8CfjB8XRDhcQFG4qdqNwiADCrnfFscWKHzSgJKBTNLISZfsTSV/I+8ZKWJWXyTzFXXl9jkImZb8ERZ2wOZX8cJ+6agQ==
X-OriginatorOrg: ddn.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: MW4PR19MB5630.namprd19.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 15824a8a-a016-4f2c-8194-08ddbad2c359
X-MS-Exchange-CrossTenant-originalarrivaltime: 04 Jul 2025 08:14:13.9012 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 753b6e26-6fd3-43e6-8248-3f1735d59bb4
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: 6VX99F0RNYNtHEztP0AXxQKrYOOubFN3PV9Va2K9YOEcn4jZZQqhN71Qv/ZJskiD
X-MS-Exchange-Transport-CrossTenantHeadersStamped: IA1PR19MB7208
X-BESS-ID: 1751616856-103833-7689-115488-1
X-BESS-VER: 2019.1_20250703.1506
X-BESS-Apparent-Source-IP: 40.107.220.90
X-BESS-Parts: H4sIAAAAAAACA4uuVkqtKFGyUioBkjpK+cVKVsYGxgZAVgZQMMnUIM3UOMXc3C
 QxNTEtxdQ8NdUgLdXEJNko2cAk2cJUqTYWAG/T56xBAAAA
X-BESS-BRTS-Status: 1
Subject: Re: [lustre-devel] [PATCH 1/2] lustre: refresh FSF licences
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
From: Andreas Dilger via lustre-devel <lustre-devel@lists.lustre.org>
Reply-To: Andreas Dilger <adilger@ddn.com>
Cc: ML LUSTRE DEVEL <lustre-devel@lists.lustre.org>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

T24gSnVsIDMsIDIwMjUsIGF0IDA0OjIxLCBYb3NlIFZhenF1ZXogUGVyZXogPHhvc2UudmF6cXVl
ekBnbWFpbC5jb20+IHdyb3RlOg0KPiANCj4+IE9uIDYvMjYvMjUgMTowMyBBTSwgQW5kcmVhcyBE
aWxnZXIgd3JvdGU6DQo+PiANCj4+IE15IHBvbGljeSBpcyB0aGF0IGl0IGlzIHVwIHRvIHRoZSBj
b3B5cmlnaHQgaG9sZGVycyB0byB1cGRhdGUgdGhlaXIgY29weXJpZ2h0cywNCj4+IHNvIEhQRSBz
aG91bGQgc3VibWl0IGNoYW5nZXMgdG8gdGhlIE9yYWNsZS9TZWFnYXRlL1h5cmF0ZXggbWVzc2Fn
ZXMsIGlmIHRoZXkgYXJlDQo+PiBzbyBpbmNsaW5lZC4NCj4gDQo+IFlvdSBhcmUgcmlnaHQsIGlu
IG15IHByZXZpb3VzIGUtbWFpbCBJIGRpZCBtaXNzIHRoZSBTZWFnYXRlLT5DcmF5LT5IUEUgc3Rl
cHMuDQo+ICggZm9yIHRoZSByZWNvcmQ6DQo+IGh0dHBzOi8vd2ViLmFyY2hpdmUub3JnL3dlYi8y
MDE5MDUxNzE4NDYzOS9odHRwOi8vaW52ZXN0b3JzLmNyYXkuY29tL3Bob2VuaXguemh0bWw/Yz05
ODM5MCZwPWlyb2wtbmV3c0FydGljbGUmSUQ9MjMwMjY5Mw0KPiBodHRwczovL3d3dy5ocGUuY29t
L3VzL2VuL25ld3Nyb29tL3ByZXNzLXJlbGVhc2UvMjAxOS8wOS9ocGUtY29tcGxldGVzLWFjcXVp
c2l0aW9uLW9mLXN1cGVyY29tcHV0aW5nLWxlYWRlci1jcmF5LWluYy5odG1sICkNCj4gDQo+IEx1
c3RyZSdzIGhpc3RvcnkgaXMgbW9yZSBjb252b2x1dGVkIHRoYW4gYSBzb2FwIG9wZXJhOg0KPiBD
bHVzdGVyIEZpbGUgU3lzdGVtcyAtPiBTdW4gTWljcm9zeXN0ZW1zIC0+IE9yYWNsZSAtPiBYeXJh
dGV4IC0+IFNlYWdhdGUgLT4gQ3JheSAtPiBIUEUNCj4gV2hhbWNsb3VkIC0+IEludGVsIC0+IERE
Tg0KDQpJJ3ZlIGxpdmVkIHRocm91Z2ggdGhhdCB3aG9sZSBzb2FwIG9wZXJhLCBzbyBJIGtub3cg
aXQgd2VsbC4gIFlvdSBtaXNzZWQgIkNsdXN0ZXJzdG9yIiB0aGF0IGV4aXN0ZWQgaW4gYSBicmFu
Y2ggYnJpZWZseSBiZXR3ZWVuIFN1biBhbmQgWHlyYXRleC4gOi0pDQoNCg0KPj4gSG93ZXZlciwg
aXQgaXNuJ3QgY2xlYXIgaWYgdGhlcmUgd2FzIGNvcHlyaWdodCB0cmFuc2ZlciBvZiB0aGUgY29k
ZSBiZXR3ZWVuIGFsbA0KPj4gb2YgdGhlc2UgY29tcGFuaWVzLCBzaW5jZSBpdCBpcyBvcGVuIHNv
dXJjZSBhbmQgdGhlIGFzc2lnbm1lbnQgaXMgbm90IHN0cmljdGx5DQo+PiBuZWNlc3NhcnkuDQo+
IA0KPiBQcmVzcyBSZWxlYXNlIGlzIHZlcnkgY2xlYXI6DQo+IA0KPiAtIFh5cmF0ZXggQWR2YW5j
ZXMgTHVzdHJlwq4gSW5pdGlhdGl2ZSwgQXNzdW1lcyBPd25lcnNoaXAgb2YgUmVsYXRlZCBBc3Nl
dHM6DQo+ICAgIGh0dHBzOi8vd2ViLmFyY2hpdmUub3JnL3dlYi8yMDEzMDIyNDA2MzEzNy9odHRw
Oi8vd3d3Lnh5cmF0ZXguY29tL25ld3MvcHJlc3MtcmVsZWFzZXMveHlyYXRleC1hZHZhbmNlcy1s
dXN0cmUlQzIlQUUtaW5pdGlhdGl2ZS1hc3N1bWVzLW93bmVyc2hpcC1yZWxhdGVkLWFzc2V0cw0K
PiAgICAiWHlyYXRleCBoYXMgcmVjZW50bHkgYWNxdWlyZWQgdGhlIG9yaWdpbmFsIEx1c3RyZSB0
cmFkZW1hcmssIGxvZ28sDQo+ICAgIHdlYnNpdGUgYW5kIGFzc29jaWF0ZWQgaW50ZWxsZWN0dWFs
IHByb3BlcnR5IGZyb20gT3JhY2xlLCBhbmQgd2lsbA0KPiAgICBhc3N1bWUgcmVzcG9uc2liaWxp
dHkgZm9yIHByb3ZpZGluZyBzdXBwb3J0IHRvIEx1c3RyZSBjdXN0b21lcnMgZ29pbmcNCj4gICAg
Zm9yd2FyZC4iDQo+IGFuZDoNCj4gLSBBY3F1aXNpdGlvbiBvZiBMdXN0cmXCriBBc3NldHMgZnJv
bSBPcmFjbGUgQ29ycG9yYXRpb246DQo+ICAgaHR0cHM6Ly93aWtpLmx1c3RyZS5vcmcvaW1hZ2Vz
LzIvMjUvTFVHMjAxMy1YeXJhdGV4X1VwZGF0ZS1LZXZpbl9DYW5hZHkucGRmDQo+ICAgIuKAoiBU
aGUgTHVzdHJlIGFzc2V0cyBpbmNsdWRlDQo+ICAgIFsuLi5dDQo+ICAgIC0gVGhlIGludGVsbGVj
dHVhbCBwcm9wZXJ0eSBvZiBhbGwgTHVzdHJlIg0KPiANCj4gJCBnaXQgZ3JlcCAtRSAiQ29weXJp
Z2h0LiooQ2x1c3RlcnxPcmFjbGV8U3VuKSIgIHwgd2MgLWwNCj4gNTIwDQo+IEF0IGxlYXN0LCB0
aGVyZSBhcmUgNTIwIGFyZSBib2d1cyBjb3B5cmlnaHQgYXNzaWdubWVudHMuDQo+IA0KPiANCj4g
QW5kIGl0IHdhcyBkb25lIHJlcGVhdGVkbHkgYmVmb3JlOg0KDQpUaG9zZSBjaGFuZ2VzIHdlcmUg
ZG9uZSBieSB0aGUgY29weXJpZ2h0IGhvbGRlcnMuICBJZiBzb21lb25lIGZyb20gSFBFIChmcm9t
IHdoaWNoIHRoZXJlIGFyZSBtYW55IGFjdGl2ZSBkZXZlbG9wZXJzIHRvZGF5KSB3YW50cyB0byBz
dWJtaXQgYSBjb3B5cmlnaHQgY2hhbmdlIHRoZW4gdGhpcyB3b3VsZCBnbGFkbHkgYmUgYWNjZXB0
ZWQuIEkgZG9uJ3QgdGhpbmsgaXQgaXMgbXkgcHJlcm9nYXRpdmUgdG8gY2hhbmdlIHRoZSBjb3B5
cmlnaHQgbm90aWNlcyBvbiB0aGVpciBiZWhhbGYuIA0KDQpDaGVlcnMsIEFuZHJlYXMNCg0KDQo+
IA0KPiBDbHVzdGVyIEZpbGUgU3lzdGVtcyAtPiBTdW4gTWljcm9zeXN0ZW1zDQo+IGh0dHBzOi8v
Z2l0LndoYW1jbG91ZC5jb20vP3A9ZnMvbHVzdHJlLXJlbGVhc2UuZ2l0O2E9Y29tbWl0ZGlmZjto
PTcwZTgwYWRlOTBhZjA5MzAwMzk2NzA2Yjg5MTBlMTk2YTc5Mjg1MjANCj4gZ2l0IHNob3cgNzBl
ODBhZGU5MGFmMDkzMDAzOTY3MDZiODkxMGUxOTZhNzkyODUyMA0KPiANCj4gU3VuIE1pY3Jvc3lz
dGVtcyAtPiBPcmFjbGUNCj4gaHR0cHM6Ly9naXQud2hhbWNsb3VkLmNvbS8/cD1mcy9sdXN0cmUt
cmVsZWFzZS5naXQ7YT1jb21taXRkaWZmO2g9MGY4ZGNhMDhhNGY2OGNiYTgyYzJjODIyOTk4ZWNj
MzA5ZDNiN2FhZg0KPiBnaXQgc2hvdyBmOTUzOTNiMGQwYTU5Y2YzZGMyZjI5Y2ZmYzM1ZGNjNGNj
OWQ3NzI4DQo+IA0KPiBXaGFtY2xvdWQgLT4gSW50ZWwNCj4gaHR0cHM6Ly9naXQud2hhbWNsb3Vk
LmNvbS8/cD1mcy9sdXN0cmUtcmVsZWFzZS5naXQ7YT1jb21taXRkaWZmO2g9MDhhYTIxN2NlNDlh
YmExZGVkNTJlMGY3YWRiOGE2MDcwMzUxMjNmZA0KPiBnaXQgc2hvdyAwOGFhMjE3Y2U0OWFiYTFk
ZWQ1MmUwZjdhZGI4YTYwNzAzNTEyM2ZkDQo+IA0KPiANCj4gSSB0aGluayBIUEUgYW5kIERETiBz
aG91bGQgcmV2aWV3IGl0Lg0KX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX18KbHVzdHJlLWRldmVsIG1haWxpbmcgbGlzdApsdXN0cmUtZGV2ZWxAbGlzdHMubHVz
dHJlLm9yZwpodHRwOi8vbGlzdHMubHVzdHJlLm9yZy9saXN0aW5mby5jZ2kvbHVzdHJlLWRldmVs
LWx1c3RyZS5vcmcK
