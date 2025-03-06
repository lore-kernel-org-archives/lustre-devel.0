Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id E9914C282D1
	for <lustre-devel@archiver.kernel.org>; Thu,  6 Mar 2025 22:15:25 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Z83dP2Z8Zz1xN5;
	Thu, 06 Mar 2025 14:15:21 -0800 (PST)
Received: from mx0f-00379502.gpphosted.com (mx0f-00379502.gpphosted.com
 [67.231.155.129])
 (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Z83dH4ftcz1wsD
 for <lustre-devel@lists.lustre.org>; Thu, 06 Mar 2025 14:15:15 -0800 (PST)
Received: from pps.filterd (m0218362.ppops.net [127.0.0.1])
 by mx0f-00379502.gpphosted.com (8.18.1.2/8.18.1.2) with ESMTP id
 526BhI6o025629
 for <lustre-devel@lists.lustre.org>; Thu, 6 Mar 2025 14:15:14 -0800
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=llnl.gov;
 h=from : to : subject :
 date : message-id : content-type : mime-version; s=02022021-podllnl;
 bh=9wTUsN+1xz18BbOK3icdoLHY/EMGwAVW+44LNbMXXPs=;
 b=HZbqil8VeFHS3kcoJL4pFDSHJFrRWXnr0AxnbKBmLQ+HGSCcxCIO9c1MkYA5RZgkZLTe
 fxFqfr/d83g3bMMPou0E0QtnASEhnJrZpsCsHLJgiNXAciC18D2thW86kK2AgaFFGzi1
 drlZ2Mxdj3PklwV5KLm+VbfNtVuWYgqQ5PEG36NH+KqXwmdB/rx6IqGKGFdcFwKDZsGz
 NGo3RHvjKADcyekQowVbZHI9RwWeHQqsk9oCqckdypSV5icrNo+fJd+vc+yLhk08QGIb
 lo1BRoFOP6VkaUoFX0LamzMWjh/fozOcgT8aNknyq9xUhgjYmUbrW2bcemWgNZ2ao/NS Cw== 
Received: from by5pr09cu001.outbound.protection.outlook.com
 (mail-westusazlp17011012.outbound.protection.outlook.com [40.93.1.12])
 by mx0f-00379502.gpphosted.com (PPS) with ESMTPS id 456xp7jc11-1
 (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT)
 for <lustre-devel@lists.lustre.org>; Thu, 06 Mar 2025 14:15:14 -0800
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=IyE2p8vkQtHmXMJlSGvnehHhzAeyzdVn4eNOoNNte6AbDXdw1BesfwxXh3sAeClB0lR4eKOoV3bJIY8hWVTIDgIz8Dagnm9mUTiXfRa+Khe1EEGq672snDy77JMRX2vl0tFf6dD1sdID2wAeB6v33Clpg6455yGsZGEebOf1VMs62Lg1ALOoiiedT79cJNjOMR0cZfIp05TX+9p5VxLrLrNUfyI6vke5t8MRwtCcXJuqh/21rDvufvZp1WDfBfrpJ682EMWo9mp9732gkOkdur6J38v8LWgdE9pPH/LTznWX/ejFVsHhyMywFBRkI2FqPiW4m4Rcqmy+TEFMAmgnCg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com; 
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=9wTUsN+1xz18BbOK3icdoLHY/EMGwAVW+44LNbMXXPs=;
 b=jFfT9wKIiAmtV9ofHy+SNMPf2bkKkn6PqLiWrYpg2rdN1scUAkaM5n977gAMdOzdnZG+uMZMuSrFVpyxTZ6u7QqXbXxp0fWs1Mj7xUkG9CANcTo4m3OYqMJyNNmkttJ+jiFVu6FdAqa2to9TajECn5YQfJE34x3zIakaHp9NDq5rCbiF9y1CXSrHqILkwm8Mzrt91Ws20SEreE233h5R9wXRrlBECoJp/nCJCUaxWREc0Oq5LnIGlbDpxxC1f0O6ZxwGp4mBzFsAfkLxLeUex8TnaiV8Xvfkf1vpYl2l9QDHS03421eLWoxvRSbv5pIBt3c6jOSQHRoDOLiXyY4tzA==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=llnl.gov; dmarc=pass action=none header.from=llnl.gov;
 dkim=pass header.d=llnl.gov; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=doellnl.onmicrosoft.com; s=selector1-doellnl-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=9wTUsN+1xz18BbOK3icdoLHY/EMGwAVW+44LNbMXXPs=;
 b=LOd4YO+qrvmieMpcZ8sYFxiAYT3dWSueLtxviv53GnTizLa8CJeOV8of08hAA36QGygm2xLOoGDj8VYt5J8YC6ljaN8MwCnd1LdofEnSq7XUgD1AmvL5Pw9YhmAai6kqyG6FutzbM//IPz4xB0qRk6tH9VDAH5qh03y49UkP8fU=
Received: from SJ0PR09MB6381.namprd09.prod.outlook.com (2603:10b6:a03:268::15)
 by PH8PR09MB9229.namprd09.prod.outlook.com (2603:10b6:510:182::10)
 with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.8511.19; Thu, 6 Mar
 2025 22:15:11 +0000
Received: from SJ0PR09MB6381.namprd09.prod.outlook.com
 ([fe80::5938:b67a:8aed:12c8]) by SJ0PR09MB6381.namprd09.prod.outlook.com
 ([fe80::5938:b67a:8aed:12c8%4]) with mapi id 15.20.8511.017; Thu, 6 Mar 2025
 22:15:10 +0000
From: "Defazio, Gian-Carlo" <defazio1@llnl.gov>
To: "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>
Thread-Topic: prevent lustre from using specific ports for socket connections
Thread-Index: AQHbjuGD40YijsJvgUqCehz3IkhwsQ==
Date: Thu, 6 Mar 2025 22:15:10 +0000
Message-ID: <SJ0PR09MB638165AB4F27BA6F6F65BD2EE3CA2@SJ0PR09MB6381.namprd09.prod.outlook.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-ms-reactions: allow
x-ms-publictraffictype: Email
x-ms-traffictypediagnostic: SJ0PR09MB6381:EE_|PH8PR09MB9229:EE_
x-ms-office365-filtering-correlation-id: 5d0b376f-cec1-4fab-e8aa-08dd5cfc5c61
x-ms-exchange-senderadcheck: 1
x-ms-exchange-antispam-relay: 0
x-microsoft-antispam: BCL:0;
 ARA:13230040|1800799024|366016|8096899003|38070700018; 
x-microsoft-antispam-message-info: =?us-ascii?Q?CPHGAsI4ZEoiFTQL3a7LgKawacM8zin1iWgLt27oklmSHs+qIqM2KiWAAyo7?=
 =?us-ascii?Q?gsPpKYiDATq9UTrWQSxgWel/lPSwfSg16UJcbQLZDSH80ApE1Eb/dReyHXv0?=
 =?us-ascii?Q?cdjJuZoM278kOxqTBr5iO7gTKjHbZt9w9VrcLMNL2ZXYDMNW+21Bv3tJ6xwD?=
 =?us-ascii?Q?QPqfYN5wJ37cbYY71MkURV0gQ4mfCgf0ehuVjteqJPOCIGonbjnnMWwIg6tQ?=
 =?us-ascii?Q?Pq7j5ilb4qXC8bRVo6qLZhs4N0Q6yK+SdCMnPZIqADgTWwVBM9+UoMVsweRw?=
 =?us-ascii?Q?cQZyM4l0X8Pqy98BqjXQ+OjTVCq5slz7GpVy4Klm+v5aRBL212COg9UWk7ZM?=
 =?us-ascii?Q?5HzpQmjL3A+HrGhcpCoy/crkqhQMn5mLEBCTcWJfYISKrJP+rwPnFzi42hzy?=
 =?us-ascii?Q?K8DW9lK0ro1xMvf0Yk4k4C+nJggCs4Mc1GPlbdldz9ldlotXmTjMX+MUGZJN?=
 =?us-ascii?Q?f1BRwq9/JtRRqPCQnY81zZqepUgzhfyqoH+J0kvZ5pIWEkhyxkiiYhcVdbVy?=
 =?us-ascii?Q?l3mIGvou/LYzT4q45K2p1yaCFxMkvFr3CBn1LJgOghwhl4pyuEhOJYPNSoGY?=
 =?us-ascii?Q?J/pqgdPsI+s/nBfU+YP3/0Cs2yUfZJKsskP8FfeEPHcwCgJdLfAdYaOvTuwN?=
 =?us-ascii?Q?xgDyty17p7pHjw460P05/3OeLNC/xE7GjJjwBdyhGPfRn7Hjx39kXRqFxnox?=
 =?us-ascii?Q?gQfx5+gLyQF17sQNTElAs2f12g/CnJjl6HdB2xzz2dMMaZ0uZrxCzEFo8OME?=
 =?us-ascii?Q?wlmuAoo3iCCPRLHmTjknrbOvMo3Blex5TJyIvH377nvq7GrvBTMrh7izETaP?=
 =?us-ascii?Q?C/l0TkEh89jIJK6ooZlRxj4D2cB5BJF7M6CRKM8dyuQPi5l+/2l/PVIP/Rsw?=
 =?us-ascii?Q?xlZLEx53msMDVDvhfKIHloNNUN3VB7yHPHPTaWmDyNRoayGzAgxwBCAaIM+y?=
 =?us-ascii?Q?Hw9nq4GymSJxAypnFdKtw7NtCuRx22/CPGatwHzXtm17mW1xydbb6u8fIR1g?=
 =?us-ascii?Q?ftuiNN0wl5cq2SIIn6MYJK8FImXkZ0rs5Eiow62kzx8M7f0BPf0hC1Jc9FNc?=
 =?us-ascii?Q?MugfYd4NPgufhz/U4BlQgwLA7jUaOYw7tDLppP3QZm9JYH6bQAw6kxIcbChU?=
 =?us-ascii?Q?Lo9k3Uo9tm9jB0bVr7On4vw6tLvShloNn0UAHuTlV8oQY1PEDrG8PvBGOiYd?=
 =?us-ascii?Q?ersNgvO9DYfqcw/8tf3PwHApa1S8W4Ry0HyabAyHU7FHnyouidlW2Y8snU4o?=
 =?us-ascii?Q?oWyA+DjZraUHZxoCzjZFNJWw7phWqN+rZDmqHyt8sOhMi6pQrkugeFBkhRQQ?=
 =?us-ascii?Q?AxqwcNX39rOCnHhQ9VqveXZ1Io5ed9MdVW+/YJyQTzHUnvLGZu5jYH4Q2/pY?=
 =?us-ascii?Q?+lDHeLSbOnXnTrng0BLCIxr0DiRkmAK9WZkctCqkw5U4GbSbZmi4bsxni5HO?=
 =?us-ascii?Q?UuZGmoah4DkISsZqzATZDJoZImUKJOtj?=
x-forefront-antispam-report: CIP:255.255.255.255; CTRY:; LANG:en; SCL:1; SRV:;
 IPV:NLI; SFV:NSPM; H:SJ0PR09MB6381.namprd09.prod.outlook.com; PTR:; CAT:NONE;
 SFS:(13230040)(1800799024)(366016)(8096899003)(38070700018); DIR:OUT; SFP:1101;
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0: =?us-ascii?Q?XlLFkHl3AaYsnW8ZfrfVROWLIxJsceHc6//O2JViQMk0SGWciyLpjdJMumte?=
 =?us-ascii?Q?fig1ZjqYcZ1CfuGT1dUa7WVojpiC/M6otY/LXJIP8KppVkIa/KSvoHqNnN1k?=
 =?us-ascii?Q?J7smYnlFBW87tBeH+91Ayi8ljMozOgHgVlhgsWKybB1K2UZL7Po1VnE9tnkB?=
 =?us-ascii?Q?Fx1fI+jbJEkhXgaJiW7yfgalvLVdltHqLH1uzFjSdhGM6DC7/Pb4OdPmngtv?=
 =?us-ascii?Q?3MWh7nxKJV299zIgpdYg3j/yWvKzXehkJSyyqDgfBpMNWhKAxzADseNQo9z1?=
 =?us-ascii?Q?w4q6tITaJxXWdcKe+Y9/Uxmu8NbJRO8f5sxqv3x5mlyoE37CY26uBCNKKdF1?=
 =?us-ascii?Q?+MwRxi3nQVxhAsdiz/5E8b2k+1kN/L9lAv3rG7mPdOMal1AOJcztvrTbOQIo?=
 =?us-ascii?Q?hnD1XwqJoZD1Viyv3NM6o/N85odZqYNORoZ9Ql7V0oS2n3oGODI84tA13HLX?=
 =?us-ascii?Q?aHXBDYh+4QTfzrEf6Es7niy+ikyo7h+1P/dCWKGfb8kSC641Un1IiCfIdC9j?=
 =?us-ascii?Q?y6hlWlkRQ9lJWfyHD5OxgXzynWvjuIrfxW8jXBMA9eBzR4ZDKAQkTN6e1sij?=
 =?us-ascii?Q?j1ar2p6CpKIY7jlA46XsycTWZZwse/d3txTlDboCaF1X37OQgyLUWLKQk9iL?=
 =?us-ascii?Q?YM0PTJLJg3ljVvQ0HLvKh8tkrUpAW+ySvAc9RGdeLbyglBkx4sHReJkSjaZ/?=
 =?us-ascii?Q?apNdilhX4SsXQ6N4rWZEVfq+/sqXMXWWVZWi4jUlG+KKPLttsTRX2ozGhlMi?=
 =?us-ascii?Q?C+9BGU2K6g3D3KG0uJJ2bCyVpl3Dg6u6QZ1ORYgolptry0a45+cLj4ma5186?=
 =?us-ascii?Q?+CQHoAZ55tg4f0/T7R8rp9Trui4OQWhotAV6XVcHL7WF18mnybsWhsuLAOYv?=
 =?us-ascii?Q?6sC9XKcupxQXNak6L81mspY/8iTaXT50ZDpJgKrIrKGKBvz1jq4HzJj3I4p1?=
 =?us-ascii?Q?id2RXPac2AjY0Vd+B5IYZvu2b9bGA4chA99gM3CDRA779+Sd+3U2p8kAjvWq?=
 =?us-ascii?Q?1ROFaG0roPU+sj+J5g58muQvoaCLk4M3DkB7U99cP9e+59cfZTwgyTrFiTgb?=
 =?us-ascii?Q?CTCNK6VW7KO0gCP9xoFDADTNK16wo75oMWxoLHXlW5HGN+oWciNuvpYHV5bO?=
 =?us-ascii?Q?IYcHFPRGpnLaWnR0thcSVgxIw4J6dtCT3W3sqmc+sf7zYwqh41G+KYELM8jb?=
 =?us-ascii?Q?lgL7EH1k938Qg4WodhLbdzTVIG14ydsX6E4gEgiGNjgZITyu7QehUTAr0cv5?=
 =?us-ascii?Q?BJdJjkIMvTEs0H9HqcXaikRnuVkzFO62ueLDNbGLE/PNdbqnFEIbzJV3LZMS?=
 =?us-ascii?Q?3tvac+Vb/8n70SHewty3EGm9r3U7hZ/7L0bPPtIFAJxoo3rtJns7VLvKIZMK?=
 =?us-ascii?Q?mh9RR6llcV+VwInkeo42T4NYRUs6xzWQST3NaJ/4x3aHVJ40YI0nGSAT3eT9?=
 =?us-ascii?Q?lCXrw34i60nCUl9jXHbUzGJX0/52Bs3epl99AHnndP6D1lKx1gfQJiZhe9Cj?=
 =?us-ascii?Q?szj6fPKqhy5v+YBRn0aOkhtpS0CdhJJ8nqbV96h1vbo60X86jbItIa1KtkG5?=
 =?us-ascii?Q?o8V2lKmmdgoQ/eIgdgPSSx9zgGKWiBwmYfhnYuwdzVyXclIo0HokA4RswjZR?=
 =?us-ascii?Q?Bg=3D=3D?=
MIME-Version: 1.0
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-0: tnVTLcMlckdd+tWyQbPQpAIs3VE10Yw/CmIT162lSlVCtmUGdbSVIz6YPv3Jzpi31IEZ2+kZyaKhwDMBitmBf84VIjNbGJKxiqknjIbxfOT2cmjgdCbReEXoKgkt+jTj5xzmHqrHK194ye4XH7ymBxAZl5S9oZK/jP+wHu6rdxcTfREEbsNKUtcSTsmGWuJpnwy5hjMj7g/50mzQabgS14iqX9rQtGDr3mSuvsy8IB/79rk7LQXQP0FgvROsxR4JceRejaaAsM/4CUnoW4PP2pypJ2G4b6Xiz+a9Z1o7iYI0VDilHIcyY2TrMAC7fONhoCAa8Ew0gWrJWSLse9ygw9lDYbgnFB6OX+Viv65qSHf4qvFQXvmfZgFCq53tcS9fKh6bTqBijsZfOxbMI8nQXtVheHN4WwtI81bKfdYP7dWdT8IQQid8cUbxKqLBpWsgf9x+2q0KXzT/Ro2Ndlh/zYGomaOvBtpQMS73wuWgRcZfSd1uJarrzu9T1dbXmDGfYHQltvV0CXuKUyRtOsKJpBsC9um6Sr1iKlIOGjSd+OB3CyyXVeu2QJCc17cR9DZVoe7gIX0/UZGWXmfpCMH1w33TuXf258c6tjDYE4zuHsh4aym9g1Igi64NzaeqD3sssAAxBWrOeiIxumYKipzZ6Q==
X-OriginatorOrg: llnl.gov
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: SJ0PR09MB6381.namprd09.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 5d0b376f-cec1-4fab-e8aa-08dd5cfc5c61
X-MS-Exchange-CrossTenant-originalarrivaltime: 06 Mar 2025 22:15:10.7615 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a722dec9-ae4e-4ae3-9d75-fd66e2680a63
X-MS-Exchange-Transport-CrossTenantHeadersStamped: PH8PR09MB9229
X-Proofpoint-ORIG-GUID: c_FNYfcqg8vyO56oZZfqscCng3xILy1d
X-Proofpoint-GUID: c_FNYfcqg8vyO56oZZfqscCng3xILy1d
X-Proofpoint-Virus-Version: vendor=baseguard
 engine=ICAP:2.0.293,Aquarius:18.0.1093,Hydra:6.0.680,FMLib:17.12.68.34
 definitions=2025-03-06_08,2025-03-06_04,2024-11-22_01
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0
 malwarescore=0 phishscore=0
 suspectscore=0 spamscore=0 lowpriorityscore=0 adultscore=0 bulkscore=0
 impostorscore=0 mlxscore=0 priorityscore=1501 clxscore=1011
 mlxlogscore=753 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.12.0-2502100000 definitions=main-2503060171
Subject: [lustre-devel] prevent lustre from using specific ports for socket
 connections
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
Content-Type: multipart/mixed; boundary="===============4188690189340432758=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============4188690189340432758==
Content-Language: en-US
Content-Type: multipart/alternative;
	boundary="_000_SJ0PR09MB638165AB4F27BA6F6F65BD2EE3CA2SJ0PR09MB6381namp_"

--_000_SJ0PR09MB638165AB4F27BA6F6F65BD2EE3CA2SJ0PR09MB6381namp_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Hi,

Is it possible to prevent lustre from using specific ports when establishin=
g a socket connection?
We have the situation where lustre may use a port (1022) and then a service=
 that needs to use that port fails to start.

Our current solution is a local patch to check the port values being iterat=
ed through in lnet/lnet/acceptor.c:lnet_connect() and to just skip over 102=
2.

Is there already a way to avoid certain ports for lustre? Either in lustre =
or via some kernel mechanism that would affect lustre?

We're considering making a more general patch that would allow specifying p=
orts to avoid by adding a module parameter to lnet but aren't sure what a g=
ood design would be. So far, the basic idea is that the user supplies a str=
ing of numbers/ranges such as "512,513-515,1022" and then a list or bitmap =
or some other data structure of ports to avoid is created and then lnet_con=
nect() checks that data structure when selecting ports.

Thanks,
Gian-Carlo

--_000_SJ0PR09MB638165AB4F27BA6F6F65BD2EE3CA2SJ0PR09MB6381namp_
Content-Type: text/html; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

<html xmlns:o=3D"urn:schemas-microsoft-com:office:office" xmlns:w=3D"urn:sc=
hemas-microsoft-com:office:word" xmlns:m=3D"http://schemas.microsoft.com/of=
fice/2004/12/omml" xmlns=3D"http://www.w3.org/TR/REC-html40">
<head>
<meta http-equiv=3D"Content-Type" content=3D"text/html; charset=3Dus-ascii"=
>
<meta name=3D"Generator" content=3D"Microsoft Word 15 (filtered medium)">
<style><!--
/* Font Definitions */
@font-face
	{font-family:"Cambria Math";
	panose-1:2 4 5 3 5 4 6 3 2 4;}
@font-face
	{font-family:Aptos;
	panose-1:2 11 0 4 2 2 2 2 2 4;}
/* Style Definitions */
p.MsoNormal, li.MsoNormal, div.MsoNormal
	{margin:0in;
	font-size:12.0pt;
	font-family:"Aptos",sans-serif;
	mso-ligatures:standardcontextual;}
span.EmailStyle17
	{mso-style-type:personal-compose;
	font-family:"Aptos",sans-serif;
	color:windowtext;}
.MsoChpDefault
	{mso-style-type:export-only;}
@page WordSection1
	{size:8.5in 11.0in;
	margin:1.0in 1.0in 1.0in 1.0in;}
div.WordSection1
	{page:WordSection1;}
--></style>
</head>
<body lang=3D"EN-US" link=3D"#467886" vlink=3D"#96607D" style=3D"word-wrap:=
break-word">
<div class=3D"WordSection1">
<p class=3D"MsoNormal"><span style=3D"font-size:11.0pt">Hi,<o:p></o:p></spa=
n></p>
<p class=3D"MsoNormal"><span style=3D"font-size:11.0pt"><o:p>&nbsp;</o:p></=
span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:11.0pt">Is it possible to p=
revent lustre from using specific ports when establishing a socket connecti=
on?<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:11.0pt">We have the situati=
on where lustre may use a port (1022) and then a service that needs to use =
that port fails to start.<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:11.0pt"><o:p>&nbsp;</o:p></=
span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:11.0pt">Our current solutio=
n is a local patch to check the port values being iterated through in lnet/=
lnet/acceptor.c:lnet_connect() and to just skip over 1022.<o:p></o:p></span=
></p>
<p class=3D"MsoNormal"><span style=3D"font-size:11.0pt"><o:p>&nbsp;</o:p></=
span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:11.0pt">Is there already a =
way to avoid certain ports for lustre? Either in lustre or via some kernel =
mechanism that would affect lustre?<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:11.0pt"><o:p>&nbsp;</o:p></=
span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:11.0pt">We're considering m=
aking a more general patch that would allow specifying ports to avoid by ad=
ding a module parameter to lnet but aren't sure what a good design would be=
. So far, the basic idea is that the
 user supplies a string of numbers/ranges such as &quot;512,513-515,1022&qu=
ot; and then a list or bitmap or some other data structure of ports to avoi=
d is created and then lnet_connect() checks that data structure when select=
ing ports.<o:p></o:p></span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:11.0pt"><o:p>&nbsp;</o:p></=
span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:11.0pt">Thanks,<o:p></o:p><=
/span></p>
<p class=3D"MsoNormal"><span style=3D"font-size:11.0pt">Gian-Carlo <o:p></o=
:p></span></p>
</div>
</body>
</html>

--_000_SJ0PR09MB638165AB4F27BA6F6F65BD2EE3CA2SJ0PR09MB6381namp_--

--===============4188690189340432758==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============4188690189340432758==--
