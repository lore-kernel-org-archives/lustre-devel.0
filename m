From: Alex Zhuravlav <bzzz@sun.com>
Date: Wed, 25 Mar 2009 19:32:39 +0300
Subject: [Lustre-devel] WBC HLD outline
In-Reply-To: <200903251917.30178.alexander.zarochentsev@sun.com>
References: <200903240058.30343.alexander.zarochentsev@sun.com>
	<200903251117.48986.alexander.zarochentsev@sun.com>
	<m3y6uungs7.fsf@bzzz.home.net>
	<200903251917.30178.alexander.zarochentsev@sun.com>
Message-ID: <m3myb9o95k.fsf@bzzz.home.net>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

>>>>> Alexander Zarochentsev (AZ) writes:

 AZ> Server MD stack has to support both WBC and non-WBC clients for the same 
 AZ> objects. It is why I think MDT layer should handle MD ops as well as 
 AZ> MDS/RAW ops. Then CMM only passes RAW operations to MDD layer, where 
 AZ> raw ops are already supported.

btw, what's problem with supporting WBC and non-WBC clients for same objects?

any time you access some object via short (MDT-OSD for WBC client) or long
(MDT-MDD-OSD) for non-WBC client) it's initialized at all layers (MDT-MDD-OSD).

-- 
thanks, Alex
