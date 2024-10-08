class User < ApplicationRecord
    # サイト管理者はユーザーを破棄する権限を持つ 
    # ユーザーが削除された時にそのユーザーに紐づいたマイクロポストも一緒に削除される
    has_many :microposts, dependent: :destroy
    has_many :active_relationships, class_name:  "Relationship",
                                  foreign_key: "follower_id",
                                  dependent:   :destroy
    has_many :passive_relationships, class_name:  "Relationship",
                                   foreign_key: "followed_id",
                                   dependent:   :destroy
    has_many :following, through: :active_relationships, source: :followed
    has_many :followers, through: :passive_relationships, source: :follower
    # :XXX_token属性を定義
    attr_accessor :remember_token, :activation_token, :reset_token
    before_save   :downcase_email
    before_create :create_activation_digest
    validates :name, presence: true,length: { maximum: 50 }
    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
    validates :email, presence: true, length: {maximum: 255} ,
                        format: { with: VALID_EMAIL_REGEX } , 
                        uniqueness: { case_sensitive: false }
    has_secure_password
    validates :password, presence: true, length: { minimum: 6 }, allow_nil: true
    
    class << self #Ruby的に正しい書き方
        # 渡された文字列のハッシュ値を返す
        def digest(string)
            cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                          BCrypt::Engine.cost
            BCrypt::Password.create(string, cost: cost)
        end
        
        # ランダムなトークンを返す
        def new_token
            SecureRandom.urlsafe_base64
        end
    end
    
    # 永続セッションのためにユーザーをデータベースに記憶する
    def remember
        #remember_tokenに　User.new_tokenを代入
        self.remember_token = User.new_token
        #validationを無視して更新　（:remember_digest属性にハッシュ化したremember_tokenを）
        update_attribute(:remember_digest, User.digest(remember_token))
    end
    
    # トークンがダイジェストと一致したらtrueを返す
    def authenticated?(attribute, token)
        digest = send("#{attribute}_digest")
        return false if digest.nil?
        BCrypt::Password.new(digest).is_password?(token)
    end
    
    # ユーザーのログイン情報を破棄する
    def forget
        update_attribute(:remember_digest, nil)
    end
    
    # アカウントを有効にする
    def activate
        update_columns(activated: true, activated_at: Time.zone.now)
    end
    
    # 有効化用のメールを送信する
    def send_activation_email
        UserMailer.account_activation(self).deliver_now
    end
    
    # パスワード再設定の属性を設定する
    def create_reset_digest
        self.reset_token = User.new_token
        update_columns(reset_digest: User.digest(reset_token), reset_sent_at: Time.zone.now)
    end
    
    # パスワード再設定のメールを送信する
    def send_password_reset_email
        UserMailer.password_reset(self).deliver_now
    end
    
    def password_reset_expired?
        reset_sent_at < 2.hours.ago
    end
    
    # 試作feedの定義
    # 完全な実装は次章の「ユーザーをフォローする」を参照
    def feed
        following_ids = "SELECT followed_id FROM relationships
                        WHERE follower_id = :user_id"
        Micropost.where("user_id IN (#{following_ids})
                        OR user_id = :user_id", user_id: id)
    end
    
    # ユーザーをフォローする
    def follow(other_user)
        following << other_user
    end
    
    # ユーザーをフォロー解除する
    def unfollow(other_user)
        active_relationships.find_by(followed_id: other_user.id).destroy
    end
    
    # 現在のユーザーがフォローしてたらtrueを返す
    def following?(other_user)
        following.include?(other_user)
    end
    
    
    private
        # メールアドレスをすべて小文字にする
        def downcase_email
          self.email.downcase!
        end
        
        # 有効化トークンとダイジェストを作成および代入する
        def create_activation_digest
          self.activation_token  = User.new_token
          self.activation_digest = User.digest(activation_token)
        end
end
