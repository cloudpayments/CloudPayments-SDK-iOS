
#define WEAKIFY_SELF	\
    __weak __typeof__((self)) self##__weak = (self)

#define STRONGIFY_SELF	\
    __strong __typeof__((self##__weak)) self = (self##__weak)
