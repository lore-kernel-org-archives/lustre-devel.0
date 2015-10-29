From: Simmons, James A. <simmonsja@ornl.gov>
Date: Thu, 29 Oct 2015 15:22:13 +0000
Subject: [lustre-devel] [PATCH 08/10] staging: lustre: remove white
 space in libcfs_hash.h
In-Reply-To: <D256A968.116805%andreas.dilger@intel.com>
References: <1446051271-25189-1-git-send-email-jsimmons@infradead.org>
	<1446051271-25189-9-git-send-email-jsimmons@infradead.org>
	<D256A968.116805%andreas.dilger@intel.com>
Message-ID: <2b25c8958e1944bbbd48b638ab7eed6f@EXCHCS32.ornl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

>>struct cfs_hash_bd {
>>-	struct cfs_hash_bucket	*bd_bucket;      /**< address of bucket */
>>-	unsigned int		bd_offset;      /**< offset in bucket */
>>+	/**< address of bucket */
>>+	struct cfs_hash_bucket	*bd_bucket;
>>+	/**< offset in bucket */
>>+	unsigned int		 bd_offset;
>> };
>
>The "/**< ... */" marker means "the field to the left", but if you are
>moving these to the line before the field you should just use "/* ... */".

Fixed.
