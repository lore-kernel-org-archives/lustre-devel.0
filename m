Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 4257AD7494D
	for <lustre-devel@archiver.kernel.org>; Tue, 29 Oct 2024 22:48:34 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4XdQQd1lGmz1x4h;
	Tue, 29 Oct 2024 15:48:25 -0700 (PDT)
Received: from mx0f-00379502.gpphosted.com (mx0f-00379502.gpphosted.com
 [67.231.155.129])
 (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4XdQQV5qxjz1x47
 for <lustre-devel@lists.lustre.org>; Tue, 29 Oct 2024 15:48:18 -0700 (PDT)
Received: from pps.filterd (m0422210.ppops.net [127.0.0.1])
 by mx0f-00379502.gpphosted.com (8.18.1.2/8.18.1.2) with ESMTP id
 49TFq4Rf007280
 for <lustre-devel@lists.lustre.org>; Tue, 29 Oct 2024 15:48:17 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=llnl.gov;
 h=from : to : subject :
 date : message-id : content-type : mime-version; s=02022021-podllnl;
 bh=pzEr0/8KIgDLmGFk7QMZugxLOuPpJcrKUpX1f9YmfDo=;
 b=eYh+Yg9Spn+NIxnXsD1ZSRBJVz2UwuKOlIUlk50DiBFUDVURHLmU/j9cfE/WNlSKVAgu
 JubHJCvKRikM8roVxipCDXZLqCMt4jh/HHLWmhcI4NFKfz0JYDqT61VpCcKHedbOMSHl
 5+o6wm3RZ07deO6AxbAbcURAs4ro36EJOJusPPN92zkNmLaqvDCVGgjZ1G6/vzekWYqT
 yb/9boVAsdlKWWXK4SuQctVwVCO8Xq8GYwWaJgRiP8eueDntZ+sl0Cul6AsRxvJnXOdf
 PgTac2EIQZC86ilPQ/zimfqVjPJs6g/H76hRz/vv5wcKDgnpDmkAL+EpWWmtFcu7UNzy dA== 
Received: from ch1pr09cu001.outbound.protection.outlook.com
 (mail-northcentralusazlp17011031.outbound.protection.outlook.com
 [40.93.20.31])
 by mx0f-00379502.gpphosted.com (PPS) with ESMTPS id 42k2qpgy43-1
 (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT)
 for <lustre-devel@lists.lustre.org>; Tue, 29 Oct 2024 15:48:16 -0700
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=jsEcnnAhxuhIPKwgzahQh1tVrCknP42j+4AVZ3Neo6f0C/JO35Tns5KPXrPKZqScKO5BrDeG+jKhiBmwj0kFcLn5s3+81G8mX0eU1D3gM8q+G0XH+DbRBUF0/PP972dI1aYd7wFfs5J+3ZsHOktoT3nPNwaNNJHt6yObDcikK47hklmzQOLfdZpFamVBqDYBa2W8Qx3RNONOkPvf2DotAFwDbLcRk4WPsQKi6+68bKJ9K8SRlpKURWAybJ0zewCMRVSIWyjasBTvwfeKte1E4/fDAA3+gI7dU2HAC1kK+n4DVXRqJ4RAgSGsNM93Qftj2qA3MDTehpi2mFIVtPQMjw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com; 
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=pzEr0/8KIgDLmGFk7QMZugxLOuPpJcrKUpX1f9YmfDo=;
 b=oKN2uyCgsW/UKBD4n2SG8heBiPuGR2sn5w1CzVYLVmI1tbFgKa+CKMFnhrcR8cbD9uktvf6y6qvxtAXuwBpRkMl8ujbgXlL+M+Z9eTI3uMKekK4LbZxYaDB0Fa09Rus8i20z3JM1ipSHOLAhBjQr6/8gzwu/Lzczqjllw8munvgNuxiiQ7ZmbxNz5cwH2KAsVUM8sekdlDkm1Sz/PumGAcKKPq38bMMmCV0G1LVbarGcILWKdGzuipAXTX+o99SEMxibwjLng/MvtrDagBaR06AgY72X2U90+4/sPkvr/8osckdUQ4LE1RZMjtgpSjNihJo7EA1etdfFsZ9q4NRbMg==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=llnl.gov; dmarc=pass action=none header.from=llnl.gov;
 dkim=pass header.d=llnl.gov; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=doellnl.onmicrosoft.com; s=selector1-doellnl-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=pzEr0/8KIgDLmGFk7QMZugxLOuPpJcrKUpX1f9YmfDo=;
 b=r9lVCOVgbRA2l63K1S8sLaLYpciz/it1c9d3ncz3hpY+/kFlO2I686zlUcblzWNWpBSWt7Uwqs6kEw4+E9AiEXbPMyk4uPJDKXSfWbyccQ2vyOD86sCzis5j6pEVV0G19M7pVLsQApNDK15WVwz4QhjeCeVLudGXmQgVNoaSEZY=
Received: from SJ0PR09MB6381.namprd09.prod.outlook.com (2603:10b6:a03:268::15)
 by DS0PR09MB11522.namprd09.prod.outlook.com (2603:10b6:8:17c::11)
 with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.8093.32; Tue, 29 Oct
 2024 22:48:14 +0000
Received: from SJ0PR09MB6381.namprd09.prod.outlook.com
 ([fe80::5938:b67a:8aed:12c8]) by SJ0PR09MB6381.namprd09.prod.outlook.com
 ([fe80::5938:b67a:8aed:12c8%5]) with mapi id 15.20.8093.027; Tue, 29 Oct 2024
 22:48:14 +0000
From: "Defazio, Gian-Carlo" <defazio1@llnl.gov>
To: "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>
Thread-Topic: make fs ro for migration
Thread-Index: AQHbKkv0BxY5+iSvpUmFp4NYJ2Mg0Q==
Date: Tue, 29 Oct 2024 22:48:14 +0000
Message-ID: <SA0PR09MB6377DECA6DCD98AF2F176D2CE34B2@SA0PR09MB6377.namprd09.prod.outlook.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-ms-reactions: allow
x-ms-publictraffictype: Email
x-ms-traffictypediagnostic: SJ0PR09MB6381:EE_|DS0PR09MB11522:EE_
x-ms-office365-filtering-correlation-id: d21f84c2-f2e0-4dd9-607a-08dcf86bc60c
x-ms-exchange-senderadcheck: 1
x-ms-exchange-antispam-relay: 0
x-microsoft-antispam: BCL:0;
 ARA:13230040|366016|1800799024|8096899003|38070700018; 
x-microsoft-antispam-message-info: =?utf-8?B?UDVnbjVyK1NXUkZvdUoxUVNxbWl6cStSbmVVcGVWZFpVZEpWTDFSZDdoNjln?=
 =?utf-8?B?Qm9qRnZNN0NMRnRPQW5hTHBLaG5obytHSkIzQ0FWVW5mY0ZiNXhqU0NkL3p4?=
 =?utf-8?B?Q1R3MkcwUGZDbWhldUpHTVpUWTRBTmJMRG93c2RvakRoVG9WMkFWb2I5bXZB?=
 =?utf-8?B?amdOSmR6ZmVJcVlVWDFNdmtEZ2N4MVc3dDA0YmFIcGNWV1JITnNXM3Q5cXVR?=
 =?utf-8?B?TnkrQnNSSGRjdnh0Q0Y2d0plT2JkdDJwZmpXQUQ2djBKaGMwOExwZFZyUjZq?=
 =?utf-8?B?N1JqZC94b1ZQNkJ2SWJmVzlEZmVWRTU5Z2RNWmY4MURzeFl3SmNtZStSYnkw?=
 =?utf-8?B?VUx4SDNyNEtLeDQrYTVPb204d1d1L3FRZXd4RDkzNzhxcERyZWdLNkpKUSt2?=
 =?utf-8?B?aU1YNC9mb3BNNG9PdElOT21LK0NnMVVTejErL2ErTjd0aFcrQzM5cGpFeTN1?=
 =?utf-8?B?Mm8wVHpuMzZxWFk0OXFTcnBMRDcrbmtUdHl3Mk84N2t1SUNkM3BZbkVBTFc5?=
 =?utf-8?B?a0NDY2ZOU3U0QTAxdVVTU1h1R2hzRDFuLy82U2NEU2cxU3lKS0UwalJNcUZ0?=
 =?utf-8?B?Y2hsVldpbFBsZlVXSFdNamVWOUN2RC9DSitzRTd3QTU2NmF6bXFZQTJBejRX?=
 =?utf-8?B?NWpvRnhXb1dIenBQVHVIWmt6RmpjdmtWVFYya3J6THhxT3F0bGhQM2JhY0lQ?=
 =?utf-8?B?Rm1tbkN5TWt0QzVkUlZES0FFUE8rVUV6cEw4MTcvcG9Dc1J0WDYyd2JxU0pp?=
 =?utf-8?B?aVRxQmJOVENCYVFIclJMMG93VWgwb0FORFJvZ0wvZUxyL1MxYlFOZUhtbFEw?=
 =?utf-8?B?ai9EQWtLdGFKd25aSW4wSGNjNU1keXJrUDgxRkp3ZzNBcDIwWXhJMk42V1JT?=
 =?utf-8?B?RHhnOS8yZnI2aDIrb3hXTUhtWlgrVUpBbnR6QUkxNHRRc1RuSlphNHFpQ2s2?=
 =?utf-8?B?WDYreEFUb1JjYWdmdUFDTVNvWHNZRERJNVRTY2w3c3FZTUVoS3p4T0lyOWwy?=
 =?utf-8?B?K0FiYkd4U0dZR1I2S25RTzVwR2piRzZBVkwxeGs3SkhOb2xFYWpqQ3NJR0ho?=
 =?utf-8?B?TDk4TkR0dkp6cjFQbDA2QTZ4Nzdlelltd3dPVFhrREV1UnBtakx1QXZJWUY1?=
 =?utf-8?B?TG8zSHNxYkgwNXpxSU5IWDNJbmlkSWc0TXZYUGVvYlJtWndVV3dYQzYvZFJT?=
 =?utf-8?B?M2E2bmxIelpXcE5pUyt1Y3ZlYzJMMTV1OHg2UzBUeUtqYVh1N3VySGlJeWJY?=
 =?utf-8?B?WTF6bWtOQUgxWUlCWjFiWGx1ZzBvckhEMm9PZS9lQXVES3UxT0FiaTg3WFZN?=
 =?utf-8?B?YzcwN1p4akFuRXJXVlo5ck83TUtyZ2pYNlFITlY5cnN6L1hyWkdrS1h1bFNX?=
 =?utf-8?B?ZTlhTTRjNExIMHhJVmlrcnV1bG5iWEp6VkF3K3lnUFJRa0I0WE1GSERaZWRs?=
 =?utf-8?B?ajl3eEZmRzhIM0dqeU1zdzdlV1dXaWZVM1lmU3hGWkRhQVNnd21DSEg0RE5q?=
 =?utf-8?B?M2lzak9TdmxURXQzRjQzNE1GNHRWVXI1YS9vNHdWWTZzTnc4MGgyditnSFdx?=
 =?utf-8?B?OWE2U3ZmSnJROXl0OHhadWxUUGF1d3B0WUpDYWFpL0s0Vnh1VEVON0s2WE5C?=
 =?utf-8?B?ZjZsZXFMQk9TcktEWERzSTdPSGxMZVJ1N1hzTmxWWG5QdnJuT2svSkVTajhR?=
 =?utf-8?B?Y1VaUHBQZWJab2x0M2lOakxvR09jdVZZNUt3MmdHK3V0OWJ0NlBjazRzNnRQ?=
 =?utf-8?B?T3d0a3RsS0RaamJSNDN4YW5HeUFDeFU3dVFFcTJaZmVIS2FUZjVpODUxSVpO?=
 =?utf-8?Q?T8rV77wZHDife5P1YFfAFzC5vbYYv28hw9fXw=3D?=
x-forefront-antispam-report: CIP:255.255.255.255; CTRY:; LANG:en; SCL:1; SRV:;
 IPV:NLI; SFV:NSPM; H:SJ0PR09MB6381.namprd09.prod.outlook.com; PTR:; CAT:NONE;
 SFS:(13230040)(366016)(1800799024)(8096899003)(38070700018); DIR:OUT; SFP:1101;
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0: =?utf-8?B?SUMrSlRkeTJmVkFvWTRVSzRSY3U0UGtqTHBaR0MwMlFYMURZRXA3WUZRdmlZ?=
 =?utf-8?B?RFB1V2IrQW5obXlVQzg4cyt0ZlI4U01vdlNvU2N3bHUzYlVsRk9oN2w2N1F3?=
 =?utf-8?B?UjlqTDNSc2VvM29KU256azVacjREWUVMNjBib0l3dzFoYlFGc3ZScHp4UU1P?=
 =?utf-8?B?VzhWaEk0anBEOHhtdC9XbEhWcGJBMDNaeThoK0VCb1poZU1OR0lvdFI3UmZK?=
 =?utf-8?B?bjF4Q3Y3R3BnS2g1OW5nTGVtOFhIaGVBSjFKQ2U1dW9uZk5JVnlhcXZwbGlL?=
 =?utf-8?B?TGRvdm4wQWtSaldCUm45eG9YSVJFdFpWYnozdkVtY0pPL3BFYm5zMjJETGZS?=
 =?utf-8?B?cWhwR3h4aWVTT05rTk13RkprQ2M1TG1vUXorME1FOXFLUzhuUmlzeGtzWWtY?=
 =?utf-8?B?NHhmM2xTYUJ1S2FlcGt0MjlzdWlVSFJ2WXZlQkZPZlI4YjM0ZllXQnc5SnpM?=
 =?utf-8?B?VENjbElKRW8zUlRRMTJlSWZDTHVya2d2OC9OSTRpUjVhWDlCM29JdHFyK2d6?=
 =?utf-8?B?SGcybTgrdGU5MnFOSG1EZ2IyQ3g1Z3huSXJLWVpPNUpONnl6SExkazlrVHpk?=
 =?utf-8?B?dUtEM0tCeE1YZkhvaTBzSUcrbmo5Q011bXFxbnBZM0dsN1JaSk41TUw3ZUV1?=
 =?utf-8?B?YzJNcVpGb3ZtWFFySEV1Ny8yYTlrTkxhTkJVaU80VVBldCtZR3YvaDBENFR0?=
 =?utf-8?B?SGJFaGFQTmlrM0ZiTVFnbWRnNWlkYnF3U1lLMnpaU0M5OEEyYWFMd1g1Zi8z?=
 =?utf-8?B?cWYwcG9UNjlWZXRHTXBBeEpjR08xaE9nZ0tpZXhKZmp0ZFRkWUNIVVg1MHZo?=
 =?utf-8?B?ck5nbFYyc05mcUhYbXp3WGxqTmhNU0xteld3YXZGdVRuOU9jZzhlLzBBbmhE?=
 =?utf-8?B?bmxpYmwrazkwOFRoZjUxZTBUUld1YnpBUU9XSFJJUnpUeUlhdDVTNjlKRU54?=
 =?utf-8?B?SEpaS2dlMVVEbzZtL21lcW56a0l0SkI1Z1U3Qld1b0lBT2RmUnNNQ0IzMTk5?=
 =?utf-8?B?K2dTNitpUld0OWpPZTJHTVo4RGhsdWxpVGE2UCtidUpvUWlkVWxuMnlWdXBv?=
 =?utf-8?B?OEpjMElaUWpUajNpVzJYVkJNcXROUGdNa0ZLelhvTHg2U3JpVXlCTk9aQ1hz?=
 =?utf-8?B?WVFxeXdlbjNmUC9SVWxuM1lPWHNaQ2JpM3kvS0NseE5jRVVwNVRrTVp4VGRX?=
 =?utf-8?B?SVJDL1ZVdjRrU2Nobk9EcFd2WFpzT3ZLcTUxK3M0M242Mjg4M1NTMUpCTGlp?=
 =?utf-8?B?aVoweTBZblRQVHpYenUrT3VhMk4yd1lXU3E3S2ZHQS9qbnR4VEVvR2s4eVNU?=
 =?utf-8?B?YlFSUjdMK2tqQXlHQ1dtOWE1VjJpZE94QjVyTENnNmcvQXNIVkRleHdodmNs?=
 =?utf-8?B?cVlaeTE4NnBkNzlKU0NmTVdBaXNNYWdKQTVWeG1rQVArNzk2cThYc0VPTjEx?=
 =?utf-8?B?SXFXY2xGZlNkRTNqK2ZJNE1XY3pWNUVxQnM3Um1Ncmdid05XMW54dkdRd24w?=
 =?utf-8?B?MGU0eitFRzJGT3dPam9jb2FTaUJFM0NKMHZVUjNTcVV2OWplblFSWjBpYjlR?=
 =?utf-8?B?cTd1YWdCUnJsL3VMTklFODNSd1RoQXR5ZDNWTU52RFptRFZPYWprdkQ3Z2Rs?=
 =?utf-8?B?MFRsdDlqaEZhN1pVUVl3R3BjRWZyVlIvdUJqWklsV0Rkb0Z6b2wxZ0NmWUhP?=
 =?utf-8?B?SWpsYTM1YUE2SEN0WUx5WDdQcUFrbkhPbUIxTzRpaTRRWmdBVDI1UHZ4bTFs?=
 =?utf-8?B?cW15djd6SlpVVlBBSFdLdHpvbnV6Mk1QVXlOanNpVWtIV2JxQVVLbFZuRjNX?=
 =?utf-8?B?TW5jd0YwV3o1dXA2dEhlZlVqSDJYYjl5TC9OSXZXZ2ZGMFdkUXUyNE9wMFlr?=
 =?utf-8?B?MzBKakdidGtGZ1FuQnh2T2g3U2tJZXBkMER0cGNKaWNQMS9aZlVQRjRrZ0dn?=
 =?utf-8?B?WjVLMzBVdTdYMTdjcG9DdnFRbUViNFU5NzhMdWdrclV2UHhxZDBmbVB4dDdn?=
 =?utf-8?B?ZTFPdDgzdFJCTHdkVjVXMDY5MDJDb3pYdHNMUzJuMm4zS2lBVnY2Uno1Sm01?=
 =?utf-8?B?T25GWjBsbC8yS25QdDZXRExhUGVoblVOc0l2SjF4eXQ5dlBDL0RabWEwOHhY?=
 =?utf-8?B?bkNDaXE3RVdXMUdxVjdDWXkrS1ROb2FWNkl4ZmE4NHV0VDNpNzQ0Uk5ORDNT?=
 =?utf-8?B?Tmc9PQ==?=
MIME-Version: 1.0
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-0: Ogaq6ebAjYCdCo/oU74X5GQ7E9pkAvixtpnRkaC0wnNuVt91LZxITpRDO5bcGUdUhUFFr9zjk2ZLX1HIYbOqC7JfUkEJc3cZYFVDcmN6tD6h6Q86rTpxv/6oIHYOvQ/UdRY9sEF5543eeaRO59hF0quoogmu8c3NBmOOy8VIK2LFjE3krwMZpHr1Ok1SDRgBgyy3/Osrqo61/t7it/ErFjRwdqGsPhouXaGK2emtqz4SFCsLxVgILpFvpEK1V4RUY/856IXLTo2g0Q/y8m+1/az82gZ3Y1GHRt2BQ2lvCyoSvoBruAtm0SYoQ7TCBwqR/ryhJoHyCEpLGTCqMDJu1KdeKSuR3I8UyBsf7a0hH6caTvf/aoqr4zgOnEU53pqJFsHCIipVtCAubkx4zxy+lPOT+GAmgMMbAEfN9LnLNgRSMoIlzaZb6Ccxyj4CIr299dNr/gRzKUbC/ljKWX0YnjNR0fAdd1dKBMB6qPpPk3FcaQAOfCRgO1/xnuwef9Y31OYBvd8CkkdRBSXeRSmT1SL9A5U7c2S4/eWhyPnmwvNilxmk8lj4kbPXcqSCPFnuhh8h4+b6VS1ahazOwSektTQH2Zs0xW1pvwRj7uyjgLd7gv2eEmtbcdR5u1DVtesSJkzsBDs1DyUKHEzIsuQFEw==
X-OriginatorOrg: llnl.gov
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: SJ0PR09MB6381.namprd09.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: d21f84c2-f2e0-4dd9-607a-08dcf86bc60c
X-MS-Exchange-CrossTenant-originalarrivaltime: 29 Oct 2024 22:48:14.7481 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a722dec9-ae4e-4ae3-9d75-fd66e2680a63
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DS0PR09MB11522
X-Proofpoint-ORIG-GUID: uVguHXQkB8TMABXV4nqFB4o4KmjH2ZBV
X-Proofpoint-GUID: uVguHXQkB8TMABXV4nqFB4o4KmjH2ZBV
X-Proofpoint-Virus-Version: vendor=baseguard
 engine=ICAP:2.0.293,Aquarius:18.0.1051,Hydra:6.0.680,FMLib:17.12.62.30
 definitions=2024-10-29_18,2024-10-29_01,2024-09-30_01
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0
 mlxlogscore=907 phishscore=0
 impostorscore=0 lowpriorityscore=0 adultscore=0 spamscore=0 mlxscore=0
 bulkscore=0 clxscore=1011 priorityscore=1501 suspectscore=0 malwarescore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.12.0-2409260000
 definitions=main-2410290172
Subject: [lustre-devel] make fs ro for migration
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
Content-Type: multipart/mixed; boundary="===============7216658753970007964=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============7216658753970007964==
Content-Language: en-US
Content-Type: multipart/alternative;
	boundary="_000_SA0PR09MB6377DECA6DCD98AF2F176D2CE34B2SA0PR09MB6377namp_"

--_000_SA0PR09MB6377DECA6DCD98AF2F176D2CE34B2SA0PR09MB6377namp_
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64

77u/DQrvu78NCkhpLA0KDQpXZeKAmXJlIGRvaW5nIGFub3RoZXIgZmlsZSBzeXN0ZW0gbWlncmF0
aW9uLiBXZeKAmWQgbGlrZSB1c2VycyB0byBoYXZlIHJlYWQtb25seSBhY2Nlc3MgdG8gdGhlIGV4
aXN0aW5nIGZpbGVzeXN0ZW0gZHVyaW5nIGFuZCB0aGVuIGZvciBhIHdoaWxlIGFmdGVyIHRoZSBm
aW5hbCBzeW5jLg0KDQpUaGUgMiBtZWNoYW5pc21zIHdl4oCZcmUgbG9va2luZyBhdCBhcmUgc2V0
dGluZyB0aGUgTURUcyByZWFkLW9ubHkgdXNpbmcg4oCcbGN0bCBzZXRfcGFyYW0gbWR0LioucmVh
ZG9ubHk9MeKAnSBhbmQgcmVtb3VudGluZyB0aGUgZmlsZXN5c3RlbSBvbiBhbGwgdGhlIGNsaWVu
dHMgdXNpbmcg4oCcbW91bnQgLW8gcmVtb3VudCxyb+KAnS4NCg0KTXkgaW1wcmVzc2lvbiBpcyB0
aGF0IGluIHRoZSBjYXNlIG9mIHNldHRpbmcgdGhlIE1EVHMgcmVhZC1vbmx5LCBmaWxlcyBhbHJl
YWR5IG9wZW5lZCBpbiB3cml0ZSBtb2RlIHdpbGwgc3RpbGwgYmUgd3JpdGFibGUuIEZvciByZW1v
dW50aW5nLCBpZiBmaWxlcyBhcmUgb3BlbmVkIGluIHdyaXRlIG1vZGUgdGhlIHJlbW91bnQgd2ls
bCBmYWlsIGFuZCBjb21wbGFpbiB0aGF0IHRoZSBmaWxlIHN5c3RlbSBpcyBidXN5LiBPdXIgY3Vy
cmVudCBwbGFuIGlzIHRvIGRvIHRoZSByZW1vdW50aW5nIG9mIGFsbCBjbGllbnRzIGJlY2F1c2Ug
aXTigJlzIGVhc2llciB0byBzZWUgaWYgc29tZSB1c2VyIGhhcyBzb21lIGZpbGUgb3BlbiBpbiB3
cml0ZSBtb2RlLg0KDQpJcyB0aGVyZSBhIHdheSB0byBtYWtlIHRoZSBmaWxlIHN5c3RlbSByZWFk
LW9ubHkgdGhhdOKAmXMgbWluaW1hbGx5IGRpc3J1cHRpdmUgdG8gdXNlcnMgYnV0IGRvZXNu4oCZ
dCBoYXZlIHRoZSBwb3RlbnRpYWwgcHJvYmxlbSBvZiBoYXZpbmcgdG8gY2hhc2UgZG93biBldmVy
eSBwcm9jZXNzIHdyaXRpbmcgdG8gdGhlIGZpbGVzeXN0ZW0/DQoNClRoYW5rcywNCkdpYW4tQ2Fy
bG8gRGVGYXppbw0KDQoNCg0K

--_000_SA0PR09MB6377DECA6DCD98AF2F176D2CE34B2SA0PR09MB6377namp_
Content-Type: text/html; charset="utf-8"
Content-Transfer-Encoding: base64

PGh0bWwgeG1sbnM6bz0idXJuOnNjaGVtYXMtbWljcm9zb2Z0LWNvbTpvZmZpY2U6b2ZmaWNlIiB4
bWxuczp3PSJ1cm46c2NoZW1hcy1taWNyb3NvZnQtY29tOm9mZmljZTp3b3JkIiB4bWxuczptPSJo
dHRwOi8vc2NoZW1hcy5taWNyb3NvZnQuY29tL29mZmljZS8yMDA0LzEyL29tbWwiIHhtbG5zPSJo
dHRwOi8vd3d3LnczLm9yZy9UUi9SRUMtaHRtbDQwIj4NCjxoZWFkPg0KPG1ldGEgaHR0cC1lcXVp
dj0iQ29udGVudC1UeXBlIiBjb250ZW50PSJ0ZXh0L2h0bWw7IGNoYXJzZXQ9dXRmLTgiPg0KPG1l
dGEgbmFtZT0iR2VuZXJhdG9yIiBjb250ZW50PSJNaWNyb3NvZnQgV29yZCAxNSAoZmlsdGVyZWQg
bWVkaXVtKSI+DQo8c3R5bGU+PCEtLQ0KLyogRm9udCBEZWZpbml0aW9ucyAqLw0KQGZvbnQtZmFj
ZQ0KCXtmb250LWZhbWlseToiQ2FtYnJpYSBNYXRoIjsNCglwYW5vc2UtMToyIDQgNSAzIDUgNCA2
IDMgMiA0O30NCkBmb250LWZhY2UNCgl7Zm9udC1mYW1pbHk6Q2FsaWJyaTsNCglwYW5vc2UtMToy
IDE1IDUgMiAyIDIgNCAzIDIgNDt9DQpAZm9udC1mYWNlDQoJe2ZvbnQtZmFtaWx5OkFwdG9zOw0K
CXBhbm9zZS0xOjIgMTEgMCA0IDIgMiAyIDIgMiA0O30NCkBmb250LWZhY2UNCgl7Zm9udC1mYW1p
bHk6Q29uc29sYXM7DQoJcGFub3NlLTE6MiAxMSA2IDkgMiAyIDQgMyAyIDQ7fQ0KLyogU3R5bGUg
RGVmaW5pdGlvbnMgKi8NCnAuTXNvTm9ybWFsLCBsaS5Nc29Ob3JtYWwsIGRpdi5Nc29Ob3JtYWwN
Cgl7bWFyZ2luOjBpbjsNCglmb250LXNpemU6MTEuMHB0Ow0KCWZvbnQtZmFtaWx5OiJBcHRvcyIs
c2Fucy1zZXJpZjsNCgltc28tbGlnYXR1cmVzOnN0YW5kYXJkY29udGV4dHVhbDt9DQouTXNvQ2hw
RGVmYXVsdA0KCXttc28tc3R5bGUtdHlwZTpleHBvcnQtb25seTsNCglmb250LXNpemU6MTEuMHB0
Ow0KCW1zby1saWdhdHVyZXM6bm9uZTt9DQpAcGFnZSBXb3JkU2VjdGlvbjENCgl7c2l6ZTo4LjVp
biAxMS4waW47DQoJbWFyZ2luOjEuMGluIDEuMGluIDEuMGluIDEuMGluO30NCmRpdi5Xb3JkU2Vj
dGlvbjENCgl7cGFnZTpXb3JkU2VjdGlvbjE7fQ0KLS0+PC9zdHlsZT4NCjwvaGVhZD4NCjxib2R5
IGxhbmc9IkVOLVVTIiBsaW5rPSIjNDY3ODg2IiB2bGluaz0iIzk2NjA3RCIgc3R5bGU9IndvcmQt
d3JhcDpicmVhay13b3JkIj4NCjxkaXYgY2xhc3M9IldvcmRTZWN0aW9uMSI+DQo8cCBjbGFzcz0i
TXNvTm9ybWFsIj48c3BhbiBzdHlsZT0iZm9udC1mYW1pbHk6JnF1b3Q7Q2FsaWJyaSZxdW90Oyxz
YW5zLXNlcmlmIj7vu788L3NwYW4+PG86cD48L286cD48L3A+DQo8cCBjbGFzcz0iTXNvTm9ybWFs
Ij48c3BhbiBzdHlsZT0iZm9udC1mYW1pbHk6JnF1b3Q7Q2FsaWJyaSZxdW90OyxzYW5zLXNlcmlm
Ij7vu788L3NwYW4+PC9wPg0KPHAgY2xhc3M9Ik1zb05vcm1hbCI+SGksPC9wPg0KPHAgY2xhc3M9
Ik1zb05vcm1hbCI+PG86cD4mbmJzcDs8L286cD48L3A+DQo8cCBjbGFzcz0iTXNvTm9ybWFsIj5X
ZeKAmXJlIGRvaW5nIGFub3RoZXIgZmlsZSBzeXN0ZW0gbWlncmF0aW9uLiBXZeKAmWQgbGlrZSB1
c2VycyB0byBoYXZlIHJlYWQtb25seSBhY2Nlc3MgdG8gdGhlIGV4aXN0aW5nIGZpbGVzeXN0ZW0g
ZHVyaW5nIGFuZCB0aGVuIGZvciBhIHdoaWxlIGFmdGVyIHRoZSBmaW5hbCBzeW5jLjwvcD4NCjxw
IGNsYXNzPSJNc29Ob3JtYWwiPjxvOnA+Jm5ic3A7PC9vOnA+PC9wPg0KPHAgY2xhc3M9Ik1zb05v
cm1hbCI+VGhlIDIgbWVjaGFuaXNtcyB3ZeKAmXJlIGxvb2tpbmcgYXQgYXJlIHNldHRpbmcgdGhl
IE1EVHMgcmVhZC1vbmx5IHVzaW5nIOKAnGxjdGwgc2V0X3BhcmFtIG1kdC4qLnJlYWRvbmx5PTHi
gJ0gYW5kIHJlbW91bnRpbmcgdGhlIGZpbGVzeXN0ZW0gb24gYWxsIHRoZSBjbGllbnRzIHVzaW5n
IOKAnG1vdW50IC1vIHJlbW91bnQscm/igJ0uPC9wPg0KPHAgY2xhc3M9Ik1zb05vcm1hbCI+PG86
cD4mbmJzcDs8L286cD48L3A+DQo8cCBjbGFzcz0iTXNvTm9ybWFsIj5NeSBpbXByZXNzaW9uIGlz
IHRoYXQgaW4gdGhlIGNhc2Ugb2Ygc2V0dGluZyB0aGUgTURUcyByZWFkLW9ubHksIGZpbGVzIGFs
cmVhZHkgb3BlbmVkIGluIHdyaXRlIG1vZGUgd2lsbCBzdGlsbCBiZSB3cml0YWJsZS4gRm9yIHJl
bW91bnRpbmcsIGlmIGZpbGVzIGFyZSBvcGVuZWQgaW4gd3JpdGUgbW9kZSB0aGUgcmVtb3VudCB3
aWxsIGZhaWwgYW5kIGNvbXBsYWluIHRoYXQgdGhlIGZpbGUgc3lzdGVtIGlzIGJ1c3kuDQogT3Vy
IGN1cnJlbnQgcGxhbiBpcyB0byBkbyB0aGUgcmVtb3VudGluZyBvZiBhbGwgY2xpZW50cyBiZWNh
dXNlIGl04oCZcyBlYXNpZXIgdG8gc2VlIGlmIHNvbWUgdXNlciBoYXMgc29tZSBmaWxlIG9wZW4g
aW4gd3JpdGUgbW9kZS48L3A+DQo8cCBjbGFzcz0iTXNvTm9ybWFsIj48bzpwPiZuYnNwOzwvbzpw
PjwvcD4NCjxwIGNsYXNzPSJNc29Ob3JtYWwiPklzIHRoZXJlIGEgd2F5IHRvIG1ha2UgdGhlIGZp
bGUgc3lzdGVtIHJlYWQtb25seSB0aGF04oCZcyBtaW5pbWFsbHkgZGlzcnVwdGl2ZSB0byB1c2Vy
cyBidXQgZG9lc27igJl0IGhhdmUgdGhlIHBvdGVudGlhbCBwcm9ibGVtIG9mIGhhdmluZyB0byBj
aGFzZSBkb3duIGV2ZXJ5IHByb2Nlc3Mgd3JpdGluZyB0byB0aGUgZmlsZXN5c3RlbT88L3A+DQo8
cCBjbGFzcz0iTXNvTm9ybWFsIj48bzpwPiZuYnNwOzwvbzpwPjwvcD4NCjxwIGNsYXNzPSJNc29O
b3JtYWwiPlRoYW5rcyw8L3A+DQo8cCBjbGFzcz0iTXNvTm9ybWFsIj5HaWFuLUNhcmxvIERlRmF6
aW88L3A+DQo8cCBjbGFzcz0iTXNvTm9ybWFsIj48bzpwPiZuYnNwOzwvbzpwPjwvcD4NCjxwIGNs
YXNzPSJNc29Ob3JtYWwiPjxvOnA+Jm5ic3A7PC9vOnA+PC9wPg0KPHAgY2xhc3M9Ik1zb05vcm1h
bCI+PG86cD4mbmJzcDs8L286cD48L3A+DQo8L2Rpdj4NCjwvYm9keT4NCjwvaHRtbD4NCg==

--_000_SA0PR09MB6377DECA6DCD98AF2F176D2CE34B2SA0PR09MB6377namp_--

--===============7216658753970007964==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============7216658753970007964==--
