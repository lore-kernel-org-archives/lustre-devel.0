From: Oleg Drokin <Oleg.Drokin@sun.com>
Date: Tue, 5 Jan 2010 17:25:41 -0500
Subject: [Lustre-devel] SOM safety
In-Reply-To: <FCF9512F-B081-4307-AA58-9A161790073D@sun.com>
References: <079601ca8e36$70c5f480$5251dd80$@com>
	<FCF9512F-B081-4307-AA58-9A161790073D@sun.com>
Message-ID: <C3EFBF69-2AD8-4492-81AD-5C2E133CE210@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

On Jan 5, 2010, at 4:50 PM, Andreas Dilger wrote:

> On 2010-01-05, at 11:39, Eric Barton wrote:
>> The MDS must guarantee that any SOM attributes it provides to its
>> clients are valid at the moment they are requested - i.e. that no file
>> stripes were updated while the SOM attributes were computed and
>> cached.  This guarantee must hold in the presence of all possible
>> failures.
>> 
>> Clients notify the MDS before they could possibly update any stripe of
>> a file (e.g. on OPEN) so that the MDS can invalidate any cached SOM
>> attributes.  Clients also notify the MDS with "done writing" when all
>> their stripe updates have committed so that the MDS can determine when
>> it may resume caching SOM attributes.
> This brings up an interesting question.  When the client does a lookup  
> on a file, or first opens it, the client gets the cached size from the  
> MDS (assuming SOM cache is valid).  However, after this initial  
> update, what guarantee does the client have that the size is still  
> valid?  Must it do further MDS getattr or OST glimpse operations in  
> order to revalidate the size?  I don't recall any lock bit that the  
> MDS gives the client that tells the client that the file size it has  
> is still valid.

Actually when I was discussed this with Vitaly it was obvious that
once size on MDS becomes invalid the server will revoke UPDATE lock
on the inode. Subsequent stat will refetch attributes (with missing
size this time).
I am not sure if this is actually implemented and I do not see anything
about it in the latest TOI.
But in the simplest case any open for write (or presence of such open at
the time of getattr rpc) would drop get the lock (or cause us not to return it).
How that (additional lock taking on a server) would impact the cpu utilization
on the server is unknown, though.

Bye,
    Oleg
