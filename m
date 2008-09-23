From: Peter Braam <Peter.Braam@Sun.COM>
Date: Wed, 24 Sep 2008 06:48:50 +0800
Subject: [Lustre-devel] Doubly indexed tree / changelogs
In-Reply-To: <48D963BE.7050305@sun.com>
Message-ID: <C4FF9352.7D86%peter.braam@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org




On 9/24/08 5:46 AM, "Nathaniel Rutman" <Nathan.Rutman@Sun.COM> wrote:

> Peter Braam wrote:
>> 
>> On 9/23/08 11:49 AM, "Nathaniel Rutman" <Nathan.Rutman@Sun.COM> wrote:
>> 
>>   
>>> I actually added a "previous record" pointer in each changelog entry,
>>> but fill it in only where it is cheap -- when the metadata object is
>>> already in the cache I record the last changelog entry there. If it's
>>> not in the cache, I don't know where the last record associated with
>>> that fid is. We could store the last record number with the inode (EA?),
>>> but that would potentially be painful if we are recording e.g. file
>>> open/closes.
>>>     
>> 
>> Previous records are free - you get the previous one from the EA in the
>> inode, and replace the inode with the record info of the record you are
>> adding.  But for rename operations and others there are multiple pointers
>> like this needed.
>>   
> Currently I'm not reading or writing any EA for the changelog. Yes, if
> you want to tie in the fwd/back ptrs to the inode itself we need to do
> this, but I thought we were specifically discussing alternatives to
> doing that here (e.g. "auxiliary directory file mapping inodes to many
> changelog entries".)

Good point.

> If we are e.g. recording every open/close for a
> file, do we really want to read/write the EA on the MDT every time, in
> addition to the changelog llog entry?

You are writing that inode anyway, so it doesn't cost more I/O if the EA is
embedded.

Peter

> 
>> Secondly, to make the changelogs useful and scalable for filesets we
>> will need to be able to list all changelog entries associated with a
>> certain inode efficiently. I see two ways to do this ? one is an
>> auxiliary directory file mapping inodes to many changelog entries, the
>> second is to embed forward and backward pointers in the changelog
>> entries to build a linked list rooted at the inode (using an EA in the
>> inode pointing to the first and last element of the list). Both have
>> some overheads. What are your thoughts?
>> 
>> 
> 
> 
> 
